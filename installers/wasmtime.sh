#!/usr/bin/env bash

WASMTIME_HOME=$HOME/.local/wasmtime

# Copied from
# https://github.com/volta-cli/volta/blob/master/dev/unix/volta-install.sh
# Locally modified.

get_latest_release() {
  curl -w "%{stderr}" --silent "https://api.github.com/repos/bytecodealliance/wasmtime/releases/latest" | \
    tr -d '\n' | \
    sed 's/.*tag_name": *"//' | \
    sed 's/".*//'
}

release_url() {
  echo "https://github.com/bytecodealliance/wasmtime/releases"
}

release_file_postfix(){
    if [ "$1" == "mingw" ]; then
        echo "zip"
    else
        echo "tar.xz"
    fi
}

download_release_from_repo() {
  local version="$1"
  local arch="$2"
  local os_info="$3"
  local tmpdir="$4"
  local postfix=$(release_file_postfix $os_info)
  local filename="wasmtime-$version-$arch-$os_info.$postfix"
  local download_file="$tmpdir/$filename"
  local archive_url="$(release_url)/download/$version/$filename"
  info $archive_url

  curl --progress-bar --show-error --location --fail "$archive_url" \
       --output "$download_file" && echo "$download_file"
}

usage() {
    cat >&2 <<END_USAGE
wasmtime-install: The installer for Wasmtime

USAGE:
    wasmtime-install [FLAGS] [OPTIONS]

FLAGS:
    -h, --help                  Prints help information

OPTIONS:
        --dev                   Compile and install Wasmtime locally, using the dev target
        --release               Compile and install Wasmtime locally, using the release target
        --version <version>     Install a specific release version of Wasmtime
END_USAGE
}

info() {
  local action="$1"
  local details="$2"
  command printf '\033[1;32m%12s\033[0m %s\n' "$action" "$details" 1>&2
}

error() {
  command printf '\033[1;31mError\033[0m: %s\n\n' "$1" 1>&2
}

warning() {
  command printf '\033[1;33mWarning\033[0m: %s\n\n' "$1" 1>&2
}

request() {
  command printf '\033[1m%s\033[0m\n' "$1" 1>&2
}

eprintf() {
  command printf '%s\n' "$1" 1>&2
}

bold() {
  command printf '\033[1m%s\033[0m' "$1"
}

# If file exists, echo it
echo_fexists() {
  [ -f "$1" ] && echo "$1"
}

detect_profile() {
  local shellname="$1"
  local uname="$2"

  if [ -f "$PROFILE" ]; then
    echo "$PROFILE"
    return
  fi

  # try to detect the current shell
  case "$shellname" in
    bash)
      # Shells on macOS default to opening with a login shell, while Linuxes
      # default to a *non*-login shell, so if this is macOS we look for
      # `.bash_profile` first; if it's Linux, we look for `.bashrc` first. The
      # `*` fallthrough covers more than just Linux: it's everything that is not
      # macOS (Darwin). It can be made narrower later if need be.
      case $uname in
        Darwin)
          echo_fexists "$HOME/.bash_profile" || echo_fexists "$HOME/.bashrc"
        ;;
        *)
          echo_fexists "$HOME/.bashrc" || echo_fexists "$HOME/.bash_profile"
        ;;
      esac
      ;;
    zsh)
      echo "$HOME/.zshrc"
      ;;
    fish)
      echo "$HOME/.config/fish/config.fish"
      ;;
    *)
      # Fall back to checking for profile file existence. Once again, the order
      # differs between macOS and everything else.
      local profiles
      case $uname in
        Darwin)
          profiles=( .profile .bash_profile .bashrc .zshrc .config/fish/config.fish )
          ;;
        *)
          profiles=( .profile .bashrc .bash_profile .zshrc .config/fish/config.fish )
          ;;
      esac

      for profile in "${profiles[@]}"; do
        echo_fexists "$HOME/$profile" && break
      done
      ;;
  esac
}

# generate shell code to source the loading script and modify the path for the input profile
build_path_str() {
  local profile="$1"
  local profile_install_dir="$2"

  if [[ $profile =~ \.fish$ ]]; then
    # fish uses a little different syntax to modify the PATH
    cat <<END_FISH_SCRIPT

set -gx WASMTIME_HOME "$profile_install_dir"

string match -r ".wasmtime" "\$PATH" > /dev/null; or set -gx PATH "\$WASMTIME_HOME/bin" \$PATH
END_FISH_SCRIPT
  else
    # bash and zsh
    cat <<END_BASH_SCRIPT

export WASMTIME_HOME="$profile_install_dir"

export PATH="\$WASMTIME_HOME/bin:\$PATH"
END_BASH_SCRIPT
  fi
}

# check for issue with WASMTIME_HOME
# if it is set, and exists, but is not a directory, the install will fail
wasmtime_home_is_ok() {
  if [ -n "${WASMTIME_HOME-}" ] && [ -e "$WASMTIME_HOME" ] && ! [ -d "$WASMTIME_HOME" ]; then
    error "\$WASMTIME_HOME is set but is not a directory ($WASMTIME_HOME)."
    eprintf "Please check your profile scripts and environment."
    return 1
  fi
  return 0
}

# Check if it is OK to upgrade to the new version
upgrade_is_ok() {
  local will_install_version="$1"
  local install_dir="$2"
  local is_dev_install="$3"

  local wasmtime_bin="$install_dir/bin/wasmtime"

  if [[ -n "$install_dir" && -x "$wasmtime_bin" ]]; then
    local prev_version="$( ($wasmtime_bin --version 2>/dev/null || echo 0.1) | sed -E 's/^.*([0-9]+\.[0-9]+\.[0-9]+).*$/\1/')"
    # if this is a local dev install, skip the equality check
    # if installing the same version, this is a no-op
    if [ "$is_dev_install" != "true" ] && [ "v$prev_version" == "$will_install_version" ]; then
      eprintf "Version $will_install_version already installed"
      return 1
    fi
    # in the future, check $prev_version for incompatible upgrades
  fi
  return 0
}

# returns the os name to be used in the packaged release,
# including the openssl info if necessary
parse_os_info() {
  local uname_str="$1"
  local openssl_version="$2"

  case "$uname_str" in
    Linux)
      echo "linux"
      ;;
    Darwin)
      echo "macos"
      ;;
    MINGW64*)
      echo "mingw"
      ;;
    *)
      return 1
  esac
  return 0
}

parse_os_pretty() {
  local uname_str="$1"

  case "$uname_str" in
    Linux)
      echo "Linux"
      ;;
    Darwin)
      echo "macOS"
      ;;
    *)
      echo "$uname_str"
  esac
}

# return true(0) if the element is contained in the input arguments
# called like:
#  if element_in "foo" "${array[@]}"; then ...
element_in() {
  local match="$1";
  shift

  local element;
  # loop over the input arguments and return when a match is found
  for element in "$@"; do
    [ "$element" == "$match" ] && return 0
  done
  return 1
}

create_tree() {
  local install_dir="$1"

  info 'Creating' "directory layout"

  # .wasmtime/
  #     bin/

  mkdir -p "$install_dir"
  mkdir -p "$install_dir"/bin
}

install_version() {
  local version_to_install="$1"
  local install_dir="$2"

  if ! wasmtime_home_is_ok; then
    exit 1
  fi

  case "$version_to_install" in
    latest)
      local latest_version="$(get_latest_release)"
      info 'Installing' "latest version of Wasmtime ($latest_version)"
      install_release "$latest_version" "$install_dir"
      ;;
    local-dev)
      info 'Installing' "Wasmtime locally after compiling"
      install_local "dev" "$install_dir"
      ;;
    local-release)
      info 'Installing' "Wasmtime locally after compiling with '--release'"
      install_local "release" "$install_dir"
      ;;
    *)
      # assume anything else is a specific version
      info 'Installing' "Wasmtime version $version_to_install"
      install_release "$version_to_install" "$install_dir"
      ;;
  esac

  if [ "$?" == 0 ]
  then
      #update_profile "$install_dir" &&
      info "Finished" 'installation. Open a new terminal to start using Wasmtime!'
  fi
}

# parse the 'version = "X.Y.Z"' line from the input Cargo.toml contents
# and return the version string
parse_cargo_version() {
  local contents="$1"

  while read -r line
  do
    if [[ "$line" =~ ^version\ =\ \"(.*)\" ]]
    then
      echo "${BASH_REMATCH[1]}"
      return 0
    fi
  done <<< "$contents"

  error "Could not determine the current version from Cargo.toml"
  return 1
}

install_release() {
  local version="$1"
  local install_dir="$2"
  local is_dev_install="false"

  info 'Checking' "for existing Wasmtime installation"
  if upgrade_is_ok "$version" "$install_dir" "$is_dev_install"
  then
    download_archive="$(download_release "$version"; exit "$?")"
    exit_status="$?"
    if [ "$exit_status" != 0 ]
    then
      error "Could not download Wasmtime version '$version'. See $(release_url) for a list of available releases"
      return "$exit_status"
    fi

    install_from_file "$download_archive" "$install_dir"
  else
    # existing legacy install, or upgrade problem
    return 1
  fi
}

install_local() {
  local dev_or_release="$1"
  local install_dir="$2"
  # this is a local install, so skip the version equality check
  local is_dev_install="true"

  info 'Checking' "for existing Wasmtime installation"
  install_version="$(parse_cargo_version "$(<Cargo.toml)" )" || return 1
  if no_legacy_install && upgrade_is_ok "$install_version" "$install_dir" "$is_dev_install"
  then
    # compile and package the binaries, then install from that local archive
    compiled_archive="$(compile_and_package "$dev_or_release")" &&
      install_from_file "$compiled_archive" "$install_dir"
  else
    # existing legacy install, or upgrade problem
    return 1
  fi
}

compile_and_package() {
  local dev_or_release="$1"

  local release_output

  # get the directory of this script
  # (from https://stackoverflow.com/a/246128)
  DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

  # call the release script to create the packaged archive file
  # '2> >(tee /dev/stderr)' copies stderr to stdout, to collect it and parse the filename
  release_output="$( "$DIR/release.sh" "--$dev_or_release" 2> >(tee /dev/stderr) )"
  [ "$?" != 0 ] && return 1

  # parse the release filename and return that
  if [[ "$release_output" =~ release\ in\ file\ (target[^\ ]+) ]]; then
    echo "${BASH_REMATCH[1]}"
  else
    error "Could not determine output filename"
    return 1
  fi
}

download_release() {
  local version="$1"

  local arch="$(get_architecture)"
  local uname_str="$(uname -s)"
  local os_info
  os_info="$(parse_os_info "$uname_str")"
  if [ "$?" != 0 ]; then
    error "The current operating system ($uname_str) does not appear to be supported by Wasmtime."
    return 1
  fi
  local pretty_os_name="$(parse_os_pretty "$uname_str")"

  info 'Fetching' "archive for $pretty_os_name, version $version"
  # store the downloaded archive in a temporary directory
  local download_dir="$(mktemp -d)"
  download_release_from_repo "$version" "$arch" "$os_info" "$download_dir"
}

install_from_file() {
  local archive="$1"
  local copy_to="$2"
  local extract_to="$(dirname $archive)"

  local filename
  if [[ $archive == *.zip ]]; then
    filename=$(basename "$archive" .zip)
  else
    filename=$(basename "$archive" .tar.xz)
  fi

  local extracted_path="$extract_to/$filename"

  create_tree "$copy_to"

  info 'Extracting' "Wasmtime binaries"
  # extract the files to the temp directory
  if [[ $archive == *.zip ]]; then
    unzip -q "$archive" -d  "$extract_to"
  else
    tar -xvf "$archive" -C "$extract_to"
  fi

  # copy the files to the specified directory
  # binaries go into the bin folder
  cp "$extracted_path/wasmtime" "$copy_to/bin"

  # the others directly into the specified folder
  cp "$extracted_path/LICENSE" "$extracted_path/README.md" "$copy_to"
}

get_architecture() {
    local arch="$(uname -m)"
    case "$arch" in
        # macOS on aarch64 says "arm64" instead.
        arm64)
            arch=aarch64
            ;;
        # Linux identifies RISC-V as "riscv64", but wasmtime tags
        # their releases using the toolchain name "riscv64gc"
        # When encountering riscv64, map it to that name.
        riscv64)
            arch=riscv64gc
            ;;
    esac
    echo "$arch"
}

check_architecture() {
  local version="$1"
  local arch="$2"
  local os="$3"

  # Local version always allowed.
  if [[ "$version" == "local"* ]]; then
      return 0
  fi

  # Otherwise, check the matrix of OS/architecture support.
  case "$arch/$os" in
      # See the comment in get_architecture regarding this name.
      riscv64gc/Linux)
          return 0
          ;;
      aarch64/Linux)
          return 0
          ;;
      aarch64/Darwin)
          return 0
          ;;
      s390x/Linux)
          return 0
          ;;
      x86_64/*)
          return 0
          ;;
  esac

  error "Sorry! Wasmtime currently only provides pre-built binaries for x86_64 (Linux, macOS, Windows), aarch64 (Linux, macOS), s390x (Linux) and riscv64 (Linux)."
  return 1
}


# return if sourced (for testing the functions above)
return 0 2>/dev/null

# default to installing the latest available version
version_to_install="latest"

# install to WASMTIME_HOME, defaulting to ~/.wasmtime
install_dir="${WASMTIME_HOME:-"$HOME/.wasmtime"}"

# parse command line options
while [ $# -gt 0 ]
do
  arg="$1"

  case "$arg" in
    -h|--help)
      usage
      exit 0
      ;;
    --dev)
      shift # shift off the argument
      version_to_install="local-dev"
      ;;
    --release)
      shift # shift off the argument
      version_to_install="local-release"
      ;;
    --version)
      shift # shift off the argument
      version_to_install="$1"
      shift # shift off the value
      ;;
    *)
      error "unknown option: '$arg'"
      usage
      exit 1
      ;;
  esac
done

check_architecture "$version_to_install" "$(get_architecture)" "$(uname)" || exit 1

install_version "$version_to_install" "$install_dir"

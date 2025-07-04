# Prevent Ctrl+S from locking terminal.
stty stop '' &> /dev/null

# append to the history file, don't overwrite it
shopt -s histappend

# Don't escape variables on tab-complete
shopt -s direxpand

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color|xterm) color_prompt=yes;;
esac

if [ "$color_prompt" = yes ]; then
    SHELL_PROMPT='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    PS1="${SHELL_PROMPT}"
else
    PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '
fi

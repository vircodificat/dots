function t() {
    dir=$(mktemp -d)
    cd $dir
    if [ -n "$TMUX" ]; then
        tmux rename-window "$dir"
    fi
}

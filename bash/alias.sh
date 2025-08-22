alias reload='source $HOME/.bashrc'

function path() {
    for p in $(echo $PATH | sed 's/:/ /g')
    do
        echo $p
    done
}

function exes() {
    IFS=:; for dir in $PATH; do find "$dir" -maxdepth 1 -type f -executable 2>/dev/null; done
}

function executable() {
    exe=$1
    command -v $exe >/dev/null 2>&1
    return $?
}

if executable "uv"; then
    alias python="uv run python"
    alias pip="uv run pip"
fi

if executable "dfrs"; then
    alias df="dfrs"
fi

if executable "nvim"; then
    alias vi='nvim'
    alias vim='nvim'
fi

if executable "exa"; then
    alias ls='exa --color=auto'
fi

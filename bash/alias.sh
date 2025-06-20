alias reload='source $HOME/.bashrc'
alias vi='nvim'
alias vim='nvim'
alias ls='exa --color=auto'

function path() {
    for p in $(echo $PATH | sed 's/:/ /g')
    do
        echo $p
    done
}

function exes() {
    IFS=:; for dir in $PATH; do find "$dir" -maxdepth 1 -type f -executable 2>/dev/null; done
}

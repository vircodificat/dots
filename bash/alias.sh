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

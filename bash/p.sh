function p() {
    if [ -z "$1" ]
    then
        cd "$HOME/projects"
    else
        if [ -n "$TMUX" ]
        then
            cd "$HOME/projects/$1" && \
                tmux rename-window "$1"
        else
            cd "$HOME/projects/$1"
        fi
    fi
}

_p_completion()
{
    CURRENT_WORD=${COMP_WORDS[$COMP_CWORD]}
    projects=$(ls -1 "$HOME/projects")
    COMPREPLY=( $(compgen -W "$projects" "$CURRENT_WORD") )
}

complete -F _p_completion p

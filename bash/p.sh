function p() {
    if [ -z "$1" ]; then
        cd "$HOME/projects"
    elif [[ "$1" == "-l" ]]; then
        ln -s "$HOME/repos/$2" "$HOME/projects/" && \
            echo "$HOME/projects/$2"
    elif [[ "$1" == "-l" ]]; then
        ln -s "$HOME/repos/$2" "$HOME/projects/" && \
            echo "$HOME/projects/$2"
    elif [[ "$1" == "-r" ]]; then
        # delete only if a symlink
        find "$HOME/projects/$2" -type l -delete && \
            echo "Removed $HOME/projects/$2"
    elif [[ "$1" == "-u" ]]; then
        echo "Updating repos in $REPOS"
        for f in $(find $REPOS -type d); do
            if [ -d "$f/.git" ]; then
                echo "$f"
                if [[ $(git -C "$f" rev-parse --is-shallow-repository) == "true" ]]; then
                    git -C "$f" fetch --depth=1
                else
                    git -C "$f" fetch
                fi
            fi
        done
    elif [ -n "$TMUX" ]; then
        cd "$HOME/projects/$1" && \
            tmux rename-window "$1"
    else
        cd "$HOME/projects/$1"
    fi
}

_p_completion()
{
    CURRENT_WORD=${COMP_WORDS[$COMP_CWORD]}

    flag=${COMP_WORDS[1]}

    if [[ "$flag" == "-l" ]]; then
        # use of /bin/ls because of possible remapping of ls
        repos=$(/bin/ls "$HOME/repos")
        COMPREPLY=( $(compgen -W "$repos" -- "$CURRENT_WORD") )
    elif [[ "$flag" == "-r" ]]; then
        projects=$(find "$HOME/projects" -type l -printf "%f ")
        COMPREPLY=( $(compgen -W "$projects" -- "$CURRENT_WORD") )
    else
        projects=$(/bin/ls "$HOME/projects")
        COMPREPLY=( $(compgen -W "$projects" -- "$CURRENT_WORD") )
    fi
}

complete -F _p_completion p

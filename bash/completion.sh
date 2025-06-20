if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

for file in $HOME/.bash/completion.d/*
do
    if [[ "$DEBUG_BASHRC" == "1" ]]; then
        echo "Completion: $file"
    fi
    [ -f $file ] && source $file
done

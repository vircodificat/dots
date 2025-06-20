export DEBUG_BASHRC=0

# Load $PATH first
source $HOME/.bash/path.sh

for file in $HOME/.bash/*
do
    if [ -f $file ]; then
        if [[ "$file" != "$HOME/.bash/path.sh" ]]; then
            if [[ "$DEBUG_BASHRC" == "1" ]]; then
                echo "$file"
            fi

            source $file
        fi
    fi
done

if test -f "$HOME/.bash_local"
then
    source "$HOME/.bash_local"
fi

###################################################
# AGGRESSIVELY DELETE ANYTHING BELOW THIS COMMENT #
###################################################

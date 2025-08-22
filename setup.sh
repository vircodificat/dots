#!/bin/bash

set -e

cd $(dirname $(realpath "$0"))


########################################
# ~/.bashrc and ~/.bash
########################################

chmod a+w $HOME/.bashrc
cp bashrc $HOME/.bashrc
chmod a-w $HOME/.bashrc

chmod -R a+w $HOME/.bash || true
rm -rf $HOME/.bash
cp -r bash $HOME/.bash

for f in $(ls -1 $HOME/.bash); do
    chmod a-w "$HOME/.bash/$f"
done
chmod a-w $HOME/.bash


########################################
# ~/.path
########################################

if [ ! -f "$HOME/.path" ]; then
    cp path $HOME/.path
fi


########################################
# ~/.gitconfig
########################################

touch $HOME/.gitconfig
chmod a+w $HOME/.gitconfig
cp gitconfig $HOME/.gitconfig
chmod a-w $HOME/.gitconfig


########################################
# ~/.tmux.conf
########################################

chmod a+w $HOME/.tmux.conf 2> /dev/null || true
cp tmux.conf $HOME/.tmux.conf
chmod a-w $HOME/.tmux.conf


########################################
# ~/.inputrc
########################################

chmod a+w $HOME/.inputrc 2> /dev/null || true
cp inputrc $HOME/.inputrc
chmod a-w $HOME/.inputrc


########################################
# Home directory cleanup
########################################

rm -r $HOME/Documents 2> /dev/null || true
rm -r $HOME/Pictures  2> /dev/null || true
rm -r $HOME/Public    2> /dev/null || true
rm -r $HOME/Videos    2> /dev/null || true
rm -r $HOME/Templates 2> /dev/null || true
rm -r $HOME/Music     2> /dev/null || true


echo "Done"

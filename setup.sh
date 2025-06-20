#!/bin/bash

set -e

chmod a+w $HOME/.gitconfig
cp gitconfig $HOME/.gitconfig
chmod a-w $HOME/.gitconfig

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

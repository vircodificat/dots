#!/bin/bash

nerdfonts_dir="$PROJECTS/nerd-fonts"
nerdfonts_commit="v3.4.0"

if [ ! -d $nerdfonts_dir ]
then
    git clone \
        --depth 1 \
        --branch $nerdfonts_commit \
        https://github.com/ryanoasis/nerd-fonts.git \
        $nerdfonts_dir
fi

cd $PROJECTS/nerd-fonts
bash install.sh

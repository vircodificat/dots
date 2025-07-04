#!/bin/bash

set -ex

neovim_dir="$PROJECTS/neovim"
neovim_commit="v0.10.0"
skip_fetch=0
prefix="$HOME/.local/neovim"
clean=1

if [ ! -d $neovim_dir ]
then
    git clone https://github.com/neovim/neovim.git $neovim_dir
else
    echo "$neovim_dir already exists, skipping cloning..."
fi

cd $neovim_dir

if [[ "$skip_fetch" == "1" ]]
then
    echo "Skipping fetch..."
else
    git fetch
fi

git checkout $neovim_commit

if [ "$clean" ]; then
    git clean -xdf
fi

# make clean
if [ ! -d build/ ]
then
    mkdir build/
fi

make deps

cd build/
cmake \
    -DCMAKE_INSTALL_PREFIX="$prefix" \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    ..

make -j $(nproc)
make install

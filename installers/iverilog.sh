#!/bin/bash

set -e

commit="v12_0"

prefix="$HOME/.local/iverilog"
install_deps="1"

if [[ $install_deps == "1" ]]; then
    sudo apt install -y \
        autoconf \
        gperf \
        make \
        gcc \
        g++ \
        bison \
        flex \

fi

if [ ! -d $REPOS/iverilog ]; then
    git clone https://github.com/steveicarus/iverilog $REPOS/iverilog
fi

cd $REPOS/iverilog
git fetch
git checkout $commit
autoconf
./configure --prefix=$prefix
make -j 10
make install

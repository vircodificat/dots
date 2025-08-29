#!/bin/bash

commit="v5.038"

prefix="$HOME/.local/verilator"

if [ ! -d $REPOS/verilator ]; then
    git clone https://github.com/verilator/verilator $REPOS/verilator
fi

cd $REPOS/verilator
git fetch $commit
git checkout $commit
autoconf
./configure --prefix=$prefix
make -j 10
make install

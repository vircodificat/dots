#!/bin/bash

set -ex

commit=v9.2.4
prefix="$HOME/.local/qemu"

#git clone https://github.com/qemu/qemu "$REPOS/qemu"
cd "$PROJECTS/qemu/"

git checkout $commit
mkdir -p build
cd build/

#sudo apt install -y \
#    ninja-build \
#    libglib2.0-dev \
#    libpixman-1-dev \
#
../configure \
    --target-list=riscv64-softmmu,riscv64-linux-user,riscv32-softmmu,riscv32-linux-user \
    --enable-user \
    --enable-slirp \
    --prefix=$prefix

ninja
ninja install

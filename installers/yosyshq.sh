#!/bin/bash

set -e

yosys_commit="v0.56"
icestorm_commit="master" # no tags or branches
nextpnr_commit="nextpnr-0.7"

install_deps="1"

function install_dependencies() {
    if [[ "$install_deps" == "1" ]]; then
        sudo apt-get install -y \
            bison \
            build-essential \
            clang \
            flex \
            gawk \
            git \
            graphviz \
            libboost-all-dev \
            libboost-dev \
            libboost-filesystem-dev \
            libboost-iostreams-dev \
            libboost-program-options-dev \
            libboost-python-dev \
            libboost-system-dev \
            libboost-thread-dev \
            libeigen3-dev \
            libffi-dev \
            libfl-dev \
            libftdi-dev \
            libreadline-dev \
            pkg-config \
            python3 \
            tcl-dev \
            xdot \
            zlib1g-dev \

    fi
}

function clone_repos() {
    if [ ! -d $REPOS/yosys ]; then
        git clone --recurse-submodules https://github.com/YosysHQ/yosys.git $REPOS/yosys
    fi

    if [ ! -d $REPOS/icestorm ]; then
        git clone https://github.com/YosysHQ/icestorm $REPOS/icestorm
    fi

    if [ ! -d $REPOS/nextpnr ]; then
        git clone --recurse-submodules https://github.com/YosysHQ/nextpnr $REPOS/nextpnr
    fi

    git -C $REPOS/yosys fetch
    git -C $REPOS/yosys checkout $yosys_commit
    git -C $REPOS/yosys submodule update

    git -C $REPOS/icestorm fetch
    git -C $REPOS/icestorm checkout $icestorm_commit

    git -C $REPOS/nextpnr fetch
    git -C $REPOS/nextpnr checkout $nextpnr_commit
    git -C $REPOS/nextpnr submodule update --init --recursive
}

function build_yosys() {
    cd $REPOS/yosys
    unset CC
    export PREFIX=$HOME/.local/yosyshq/yosys
    make -j $(nproc)
    make install
}

function build_icestorm() {
    cd $REPOS/icestorm
    prefix=$HOME/.local/yosyshq/icestorm
    PREFIX=$prefix make -j $(nproc)
    PREFIX=$prefix make install
}

function build_nextpnr() {
    cd $REPOS/nextpnr
    unset CC
    export PREFIX=$HOME/.local/yosyshq/nextpnr
    mkdir -p build
    cd build
    cmake .. \
        -DARCH=ice40 \
        -DICESTORM_INSTALL_PREFIX=$HOME/.local/yosyshq/icestorm \
        -DCMAKE_INSTALL_PREFIX=$PREFIX \

    make -j $(nproc)
    make install
}

install_dependencies
clone_repos
build_yosys
build_icestorm
build_nextpnr

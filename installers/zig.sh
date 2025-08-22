#!/bin/bash

set -ex

include_zls=0
version="0.15.1"

download_url="https://ziglang.org/download/${version}/zig-x86_64-linux-${version}.tar.xz"

mkdir -p /tmp/zig
cd /tmp/zig
curl -SsL $download_url -o zig.tar.xz
tar xvf zig.tar.xz
dirname=$(tar tf zig.tar.xz | head -n1)
rm -rf $HOME/.local/zig
mv $dirname $HOME/.local/zig

if [[ "$include_zls" == "1" ]]; then
    if [ ! -d "$PROJECTS/zls" ]; then
        git clone https://github.com/zigtools/zls "$PROJECTS/zls"
    fi
    cd $PROJECTS/zls
    git checkout "$version"
    zig build -Doptimize=ReleaseSafe
    cp zig-out/bin/zls $HOME/.local/bin
fi

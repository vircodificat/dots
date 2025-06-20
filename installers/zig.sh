#!/bin/bash

set -ex

include_zls=1
version="0.14.0"

download_url="https://ziglang.org/download/${version}/zig-linux-x86_64-0.14.0.tar.xz"

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

#!/bin/bash

set -e

mapfile -t languages <<EOF
    firrtl
    zig
EOF

sos=()
wasms=()

mkdir -p $PROJECTS/treesitter
cd $PROJECTS/treesitter

for language in ${languages[@]}; do
    echo "Building $language"
    if [[ ! -d tree-sitter-$language ]]; then
        git clone "https://github.com/tree-sitter-grammars/tree-sitter-$language"
    fi
    cd "tree-sitter-$language"
    if tree-sitter generate && tree-sitter build && tree-sitter build -w; then
        so=$(realpath "$language.so")
        sos+=($so)

        wasm=$(realpath $(ls -1 *.wasm))
        wasms+=($wasm)
    else
        echo "(failed)"
    fi
    cd ..
done

mkdir -p build

for so in ${sos[@]}; do
    cp $so build
done

for wasm in ${wasms[@]}; do
    cp $wasm build
done

echo
echo "Finished:"
for f in $(ls build); do
    echo $(realpath build/$f)
done

#!/bin/bash

set -ex

llvm_dir="$PROJECTS/llvm"
llvm_commit="llvmorg-20.1.8"
llvm_projects="clang;lld;lldb;mlir" 
llvm_targets="RISCV;X86;WebAssembly" 
threads=4


clean=0
skip_fetch=0
prefix="$HOME/.local/llvm"

if [ ! -d $llvm_dir ]
then
    git clone https://github.com/llvm/llvm-project.git $llvm_dir --depth=1 --branch=$llvm_commit --filter=blob:none
else
    echo "$llvm_dir already exists, skipping cloning..."
fi

cd $llvm_dir

if [[ "$skip_fetch" == "1" ]]
then
    echo "Skipping fetch..."
else
    git fetch
fi

git checkout $llvm_commit

if [[ "$clean" == "1" ]]; then
    git clean -xdf
fi

mkdir -p build
cd build/

cmake -G Ninja ../llvm \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_ENABLE_PROJECTS=$llvm_projects \
  -DLLVM_PARALLEL_COMPILE_JOBS=$threads \
  -DLLVM_PARALLEL_LINK_JOBS=$threads \
  -DCLANG_DEFAULT_LINKER=lld \
  -DLLVM_ENABLE_ASSERTIONS=OFF \
  -DLLVM_TARGETS_TO_BUILD=$llvm_targets \
  -DLLVM_INSTALL_BINUTILS_SYMLINKS=ON \
  -DCMAKE_INSTALL_PREFIX=$prefix

ninja
ninja install

#!/bin/bash

set -e

export PROFILE='' # disable updating of .bashrc
export NVM_DIR=$HOME/.local/nvm

mkdir -p $NVM_DIR
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

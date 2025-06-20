#!/bin/sh

set -ex

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > /tmp/rustup-init.sh
bash /tmp/rustup-init.sh -y --no-modify-path
rm /tmp/rustup-init.sh

#!/bin/bash

python_version="cpython-3.13.7-linux-x86_64-gnu"

curl -LsSf https://astral.sh/uv/install.sh | sh
uv python install $python_version

#!/bin/bash

set -xe

prefix="$HOME/.local/bin"
url="https://github.com/yt-dlp/yt-dlp/releases/download/2025.08.20/yt-dlp_linux"
curl -SsL -o "$prefix/yt-dlp" "$url"
chmod +x "$prefix/yt-dlp"

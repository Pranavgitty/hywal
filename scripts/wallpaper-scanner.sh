#!/usr/bin/env bash

set -euo pipefail

DIR="$HOME/Pictures/Switcher"

[[ -d "$DIR" ]] || exit 0

find "$DIR" \
    -maxdepth 1 \
    -type f \
    \( \
        -iname "*.png" \
        -o -iname "*.jpg" \
        -o -iname "*.jpeg" \
        -o -iname "*.webp" \
        -o -iname "*.bmp" \
    \) \
| sort
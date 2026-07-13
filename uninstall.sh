#!/usr/bin/env bash

set -euo pipefail

echo "Removing HyWal..."

pkill hywald 2>/dev/null || true

rm -f ~/.local/bin/hywal
rm -f ~/.local/bin/hywalctl
rm -f ~/.local/bin/hywald

rm -rf ~/.local/share/hywal
rm -rf ~/.config/quickshell/hywal

rm -f /tmp/hywal.sock
rm -f /tmp/hywal.state

echo "HyWal removed."
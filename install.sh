#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BIN_DIR="$HOME/.local/bin"
DATA_DIR="$HOME/.local/share/hywal"
QS_DIR="$HOME/.config/quickshell/hywal"

echo "==> Building HyWal..."

cd "$ROOT/controller"
cargo build --release

echo "==> Creating directories..."

mkdir -p "$BIN_DIR"
mkdir -p "$DATA_DIR"
mkdir -p "$HOME/.config/quickshell"

echo "==> Installing binaries..."

install -Dm755 target/release/hywalctl "$BIN_DIR/hywalctl"
install -Dm755 target/release/hywald "$BIN_DIR/hywald"

echo "==> Installing scanner..."

install -Dm755 \
    "$ROOT/scripts/wallpaper-scanner.sh" \
    "$DATA_DIR/wallpaper-scanner.sh"

echo "==> Installing Quickshell config..."

rm -rf "$QS_DIR"
cp -r "$ROOT/quickshell" "$QS_DIR"

echo
echo "======================================="
echo "HyWal installed successfully!"
echo "======================================="
echo
echo "Installed:"
echo "  Binaries : $BIN_DIR"
echo "  Scripts  : $DATA_DIR"
echo "  Config   : $QS_DIR"
echo
echo "Make sure ~/.local/bin is in your PATH."
echo
echo "To start the daemon:"
echo "  hywald"
echo
echo "To toggle the switcher:"
echo "  hywalctl toggle"
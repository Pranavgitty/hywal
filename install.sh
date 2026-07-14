#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BIN_DIR="$HOME/.local/bin"
DATA_DIR="$HOME/.local/share/hywal"
QS_DIR="$HOME/.config/quickshell/hywal"
MATUGEN_DIR="$HOME/.config/matugen"
MATUGEN_TEMPLATE_DIR="$MATUGEN_DIR/templates"
MATUGEN_CONFIG="$MATUGEN_DIR/config.toml"
CAELESTIA_DIR="$HOME/.config/quickshell/caelestia"
CAELESTIA_STATE_DIR="$HOME/.local/state/caelestia"

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

echo "==> Installing Matugen templates..."

install -Dm644 \
    "$ROOT/templates/matugen/quickshell.json" \
    "$MATUGEN_TEMPLATE_DIR/hywal-quickshell.json"

MATUGEN_TEMPLATES=$(printf '%s\n' \
    '[templates.hywal_quickshell]' \
    'input_path = "~/.config/matugen/templates/hywal-quickshell.json"' \
    'output_path = "~/.local/state/quickshell/generated/colors.json"')

if [[ -d "$CAELESTIA_DIR" ]]; then
    install -Dm755 \
        "$ROOT/scripts/apply-caelestia-theme.py" \
        "$BIN_DIR/hywal-apply-caelestia-theme"
    install -Dm644 \
        "$ROOT/templates/matugen/caelestia-scheme.json" \
        "$MATUGEN_TEMPLATE_DIR/hywal-caelestia-scheme.json"
    mkdir -p "$CAELESTIA_STATE_DIR"

    MATUGEN_TEMPLATES+=$(printf '\n\n%s\n%s\n%s' \
        '[templates.hywal_caelestia]' \
        'input_path = "~/.config/matugen/templates/hywal-caelestia-scheme.json"' \
        'output_path = "~/.local/state/caelestia/scheme.json"' \
        'post_hook = "hywal-apply-caelestia-theme"')
else
    echo "    Caelestia was not found; skipping its optional Matugen template."
fi

echo "==> Configuring Matugen..."

mkdir -p "$MATUGEN_DIR"
touch "$MATUGEN_CONFIG"

MATUGEN_CONFIG_TMP=$(mktemp "$MATUGEN_DIR/config.toml.XXXXXX")
awk '
    /# >>> HyWal Matugen integration >>>/ { skip = 1; next }
    /# <<< HyWal Matugen integration <<</ { skip = 0; next }
    !skip { print }
' "$MATUGEN_CONFIG" > "$MATUGEN_CONFIG_TMP"

printf '\n# >>> HyWal Matugen integration >>>\n%s\n# <<< HyWal Matugen integration <<<\n' \
    "$MATUGEN_TEMPLATES" >> "$MATUGEN_CONFIG_TMP"
mv "$MATUGEN_CONFIG_TMP" "$MATUGEN_CONFIG"

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

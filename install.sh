#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BIN_DIR="${HOME}/.local/bin"
DATA_DIR="${HOME}/.local/share/hywal"
QS_DIR="${HOME}/.config/quickshell/hywal"
MATUGEN_DIR="${HOME}/.config/matugen"
MATUGEN_TEMPLATE_DIR="${MATUGEN_DIR}/templates"
MATUGEN_CONFIG="${MATUGEN_DIR}/config.toml"
CAELESTIA_DIR="${HOME}/.config/caelestia"
CAELESTIA_LEGACY_DIR="${HOME}/.config/quickshell/caelestia"
CAELESTIA_STATE_DIR="${HOME}/.local/state/caelestia"

# Default wallpaper directory (can be overridden by config)
DEFAULT_WALLPAPER_DIR="${HOME}/Pictures/Switcher"
STATE_DIR="${HOME}/.local/state/hywal"
CONFIG_DIR="${HOME}/.config/hywal"

check_dependency() {
    local cmd="$1"
    local pkg="${2:-}"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "ERROR: Required command '$cmd' not found in PATH" >&2
        if [[ -n "$pkg" ]]; then
            echo "       Please install it (e.g., $pkg)" >&2
        fi
        return 1
    fi
    return 0
}

echo "==> Checking dependencies..."

missing=0
check_dependency "cargo" "rust (https://rustup.rs/)" || missing=1
check_dependency "rustc" "rust (https://rustup.rs/)" || missing=1
check_dependency "qs" "quickshell" || missing=1
check_dependency "hyprctl" "hyprland" || missing=1
check_dependency "awww" "awww (https://github.com/TommyTran732/Aww)" || missing=1
check_dependency "matugen" "matugen (https://github.com/varmd/matugen)" || missing=1
# ImageMagick is optional - fallback to original image if not available
if ! command -v magick >/dev/null 2>&1 && ! command -v convert >/dev/null 2>&1; then
    echo "WARN: ImageMagick (magick/convert) not found - thumbnails will use original images" >&2
fi
# Python is needed for Caelestia integration
if ! command -v python3 >/dev/null 2>&1; then
    echo "WARN: python3 not found - Caelestia integration will not work" >&2
fi

if [[ $missing -ne 0 ]]; then
    echo "ERROR: Missing required dependencies. Please install them before continuing." >&2
    exit 1
fi

echo "==> Building HyWal..."

cd "$ROOT/controller"
cargo build --release

echo "==> Creating directories..."

mkdir -p "$BIN_DIR"
mkdir -p "$DATA_DIR"
mkdir -p "${HOME}/.config/quickshell"
mkdir -p "$STATE_DIR"
mkdir -p "$CONFIG_DIR"
mkdir -p "$DEFAULT_WALLPAPER_DIR"

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

if [[ -d "$CAELESTIA_DIR" || -d "$CAELESTIA_LEGACY_DIR" ]]; then
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

echo "==> Creating default config..."

CONFIG_FILE="${CONFIG_DIR}/config.json"
if [[ ! -f "$CONFIG_FILE" ]]; then
    cat > "$CONFIG_FILE" <<EOF
{
  "wallpaper_directory": "$DEFAULT_WALLPAPER_DIR",
  "state_directory": "$STATE_DIR",
  "animation_duration": 200,
  "default_view": "coverflow"
}
EOF
    echo "    Created default config at $CONFIG_FILE"
else
    echo "    Config already exists at $CONFIG_FILE, leaving unchanged"
fi

echo
echo "======================================="
echo "HyWal installed successfully!"
echo "======================================="
echo
echo "Installed:"
echo "  Binaries : $BIN_DIR"
echo "  Scripts  : $DATA_DIR"
echo "  Config   : $QS_DIR"
echo "  State    : $STATE_DIR"
echo "  Config   : $CONFIG_FILE"
echo "  Wallpapers: $DEFAULT_WALLPAPER_DIR"
echo
echo "Make sure ~/.local/bin is in your PATH."
echo
echo "To start the daemon:"
echo "  hywald"
echo
echo "To toggle the switcher:"
echo "  hywalctl toggle"
echo
echo "For more commands:"
echo "  hywalctl --help"
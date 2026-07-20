#!/usr/bin/env bash

set -euo pipefail

echo "Removing HyWal..."

pkill hywald 2>/dev/null || true

rm -f ~/.local/bin/hywal
rm -f ~/.local/bin/hywalctl
rm -f ~/.local/bin/hywald
rm -f ~/.local/bin/hywal-apply-caelestia-theme

rm -rf ~/.local/share/hywal
rm -rf ~/.config/quickshell/hywal
rm -rf ~/.local/state/hywal
rm -rf ~/.config/hywal
rm -f /tmp/hywal.sock
rm -f /tmp/hywal.state

# Clean up Matugen config - remove HyWal integration section
MATUGEN_CONFIG="${HOME}/.config/matugen/config.toml"
if [[ -f "$MATUGEN_CONFIG" ]]; then
    MATUGEN_CONFIG_TMP=$(mktemp "$MATUGEN_DIR/config.toml.XXXXXX")
    awk '
        /# >>> HyWal Matugen integration >>>/ { skip = 1; next }
        /# <<< HyWal Matugen integration <<</ { skip = 0; next }
        !skip { print }
    ' "$MATUGEN_CONFIG" > "$MATUGEN_CONFIG_TMP"
    mv "$MATUGEN_CONFIG_TMP" "$MATUGEN_CONFIG"
    echo "Cleaned Matugen config"
fi

# Remove Matugen templates
rm -f ~/.config/matugen/templates/hywal-quickshell.json
rm -f ~/.config/matugen/templates/hywal-caelestia-scheme.json

echo "HyWal removed."
#!/usr/bin/env bash

set -euo pipefail

DIR="$HOME/Pictures/Switcher"
CACHE_DIR="${XDG_CACHE_HOME:-"$HOME/.cache"}/hywal/wallpapers"
THUMBNAIL_SIZE="860x540"

[[ -d "$DIR" ]] || exit 0

mkdir -p "$CACHE_DIR"

thumbnail_for() {
    local wallpaper="$1"
    local fingerprint
    local thumbnail
    local temporary

    # Changing either the source file or its contents produces a new cache key.
    fingerprint="$(printf '%s:%s' "$wallpaper" "$(stat -c '%Y:%s' "$wallpaper")" | sha256sum | cut -d' ' -f1)"
    thumbnail="$CACHE_DIR/$fingerprint.webp"

    if [[ ! -f "$thumbnail" ]]; then
        temporary="$(mktemp "$CACHE_DIR/.${fingerprint}.XXXXXX.webp")"
        if command -v magick >/dev/null 2>&1; then
            magick "${wallpaper}[0]" -auto-orient -thumbnail "$THUMBNAIL_SIZE" \
                -strip -quality 82 "$temporary" || rm -f "$temporary"
        elif command -v convert >/dev/null 2>&1; then
            convert "${wallpaper}[0]" -auto-orient -thumbnail "$THUMBNAIL_SIZE" \
                -strip -quality 82 "$temporary" || rm -f "$temporary"
        else
            rm -f "$temporary"
        fi

        [[ -f "$temporary" ]] && mv -f "$temporary" "$thumbnail"
    fi

    # Falling back to the original keeps the switcher usable without
    # ImageMagick; otherwise the UI always reads the persistent thumbnail.
    printf '%s' "$( [[ -f "$thumbnail" ]] && printf '%s' "$thumbnail" || printf '%s' "$wallpaper" )"
}

while IFS= read -r wallpaper; do
    thumbnail="$(thumbnail_for "$wallpaper")"
    printf '%s\t%s\n' "$wallpaper" "$thumbnail"
done < <(
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
)

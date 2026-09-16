#!/bin/sh
# Symlink (or copy) the plugin into the DMS plugin directory, then scan for it
# in DMS Settings → Plugins.
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
DEST="${XDG_CONFIG_HOME:-$HOME/.config}/DankMaterialShell/plugins"
mkdir -p "$DEST"
if [ "$1" = "copy" ]; then
    rm -rf "$DEST/KatakanaWidget"
    cp -rL "$DIR/KatakanaWidget" "$DEST/KatakanaWidget"
    echo "copied to $DEST/KatakanaWidget"
else
    ln -sfn "$DIR/KatakanaWidget" "$DEST/KatakanaWidget"
    echo "linked $DEST/KatakanaWidget -> $DIR/KatakanaWidget"
fi
if command -v dms >/dev/null 2>&1; then
    dms ipc call plugins scan 2>/dev/null || true
fi
echo "Now: DMS Settings → Plugins → Scan → enable 'Katakana'"
echo "     bar pill:       Settings → DankBar → layout → add katakanaWidget"
echo "     desktop widget: Settings → Desktop Widgets → add it, right-click drag to move/resize"

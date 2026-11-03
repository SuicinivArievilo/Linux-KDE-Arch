#!/usr/bin/env bash
set -e

echo "Removendo KDE Taskbar Hover Peek..."

SCRIPTS_DIR="$HOME/.local/share/kwin/scripts"
for d in "$SCRIPTS_DIR"/taskbarhoverpeek*; do
    [ -e "$d" ] || continue
    old_id=$(basename "$d")
    kwriteconfig6 --file kwinrc --group Plugins --key "${old_id}Enabled" --delete 2>/dev/null || true
    qdbus6 org.kde.KWin /Scripting org.kde.kwin.Scripting.unloadScript "$old_id" >/dev/null 2>&1 || true
    rm -rf "$d"
done

rm -f "$SCRIPTS_DIR/main.qml"
rm -f "$HOME/.config/taskbarhoverpeek.qml"
rm -f "$HOME/.local/bin/recarregar-peek"

qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null || true

echo "Taskbar Hover Peek removido com sucesso!"

#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing KDE Taskbar Hover Peek..."

mkdir -p "$HOME/.config" "$HOME/.local/bin" "$HOME/.local/share/kwin/scripts"

# 1. Copy the main QML script and the reload utility
cp "$SCRIPT_DIR/taskbarhoverpeek.qml" "$HOME/.config/taskbarhoverpeek.qml"
cp "$SCRIPT_DIR/reload-peek" "$HOME/.local/bin/reload-peek"
chmod +x "$HOME/.local/bin/reload-peek"
ln -sf "$HOME/.local/bin/reload-peek" "$HOME/.local/bin/recarregar-peek"

# 2. Enable highlightWindows=true across all Plasma Task Manager panels
qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '
var allPanels = panels();
for (var i = 0; i < allPanels.length; i++) {
    var widgets = allPanels[i].widgets();
    for (var j = 0; j < widgets.length; j++) {
        if (widgets[j].type === "org.kde.plasma.icontasks" || widgets[j].type === "org.kde.plasma.taskmanager") {
            widgets[j].currentConfigGroup = ["General"];
            widgets[j].writeConfig("highlightWindows", true);
        }
    }
}
' 2>/dev/null || true

# 3. Configure clean, snappy window transitions (AnimationDurationFactor=0.5, disable MagicLamp/Scale/Squash)
kwriteconfig6 --file kdeglobals --group KDE --key AnimationDurationFactor --notify 0.5
kwriteconfig6 --file kwinrc --group Plugins --key magiclampEnabled false
kwriteconfig6 --file kwinrc --group Plugins --key squashEnabled false
kwriteconfig6 --file kwinrc --group Plugins --key scaleEnabled false
qdbus6 org.kde.KWin /Effects org.kde.kwin.Effects.unloadEffect magiclamp 2>/dev/null || true
qdbus6 org.kde.KWin /Effects org.kde.kwin.Effects.unloadEffect squash 2>/dev/null || true
qdbus6 org.kde.KWin /Effects org.kde.kwin.Effects.unloadEffect scale 2>/dev/null || true
qdbus6 org.kde.KWin /Effects org.kde.kwin.Effects.loadEffect highlightwindow 2>/dev/null || true

# 4. Load and activate the KWin script
"$HOME/.local/bin/reload-peek"

echo "Installation completed successfully!"

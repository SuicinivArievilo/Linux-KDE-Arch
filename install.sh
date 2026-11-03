#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Instalando KDE Taskbar Hover Peek..."

mkdir -p "$HOME/.config" "$HOME/.local/bin" "$HOME/.local/share/kwin/scripts"

# 1. Copia o QML principal e o utilitário recarregar-peek
cp "$SCRIPT_DIR/taskbarhoverpeek.qml" "$HOME/.config/taskbarhoverpeek.qml"
cp "$SCRIPT_DIR/recarregar-peek" "$HOME/.local/bin/recarregar-peek"
chmod +x "$HOME/.local/bin/recarregar-peek"

# 2. Ativa highlightWindows=true em todos os painéis (Gerenciador de tarefas apenas com ícones)
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

# 3. Configura a transição rápida/limpa (AnimationDurationFactor=0.5, sem MagicLamp/Scale/Squash)
kwriteconfig6 --file kdeglobals --group KDE --key AnimationDurationFactor --notify 0.5
kwriteconfig6 --file kwinrc --group Plugins --key magiclampEnabled false
kwriteconfig6 --file kwinrc --group Plugins --key squashEnabled false
kwriteconfig6 --file kwinrc --group Plugins --key scaleEnabled false
qdbus6 org.kde.KWin /Effects org.kde.kwin.Effects.unloadEffect magiclamp 2>/dev/null || true
qdbus6 org.kde.KWin /Effects org.kde.kwin.Effects.unloadEffect squash 2>/dev/null || true
qdbus6 org.kde.KWin /Effects org.kde.kwin.Effects.unloadEffect scale 2>/dev/null || true
qdbus6 org.kde.KWin /Effects org.kde.kwin.Effects.loadEffect highlightwindow 2>/dev/null || true

# 4. Instala e ativa o script no KWin
"$HOME/.local/bin/recarregar-peek"

echo "Instalação concluída com sucesso!"

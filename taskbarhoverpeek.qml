import QtQuick
import org.kde.kwin
import org.kde.plasma.workspace.dbus as DBus

Item {
    id: root
    property string currentKey: ""
    property var currentIds: []
    property var elevatedWins: []

    function highlight(winIds) {
        DBus.SessionBus.asyncCall({
            service: "org.kde.KWin.HighlightWindow",
            path: "/org/kde/KWin/HighlightWindow",
            iface: "org.kde.KWin.HighlightWindow",
            member: "highlightWindows",
            arguments: [winIds],
            signature: "(as)"
        });
    }

    function restoreElevated() {
        for (let i = 0; i < root.elevatedWins.length; i++) {
            const item = root.elevatedWins[i];
            if (item.win) {
                item.win.keepAbove = item.origKeepAbove;
            }
        }
        root.elevatedWins = [];
    }

    function elevateSmallWindows(winIds) {
        root.restoreElevated();
        if (winIds.length <= 1) return;

        const wins = Workspace.windows;
        const groupWins = [];
        for (let i = 0; i < wins.length; i++) {
            const w = wins[i];
            if (w.normalWindow && winIds.indexOf(String(w.internalId)) !== -1) {
                groupWins.push(w);
            }
        }
        if (groupWins.length <= 1) return;

        // Ordena da maior área para a menor área
        groupWins.sort(function(a, b) {
            const areaA = a.frameGeometry.width * a.frameGeometry.height;
            const areaB = b.frameGeometry.width * b.frameGeometry.height;
            return areaB - areaA;
        });

        // Mantém a janela maior (ex: Biblioteca da Steam) na base e eleva as menores (ex: Lista de amigos e Chat) por cima dela
        const saved = [];
        for (let i = 1; i < groupWins.length; i++) {
            const w = groupWins[i];
            saved.push({ win: w, origKeepAbove: w.keepAbove });
            w.keepAbove = true;
        }
        root.elevatedWins = saved;
    }

    function isInsidePopup(pos, wins) {
        for (let i = 0; i < wins.length; i++) {
            const w = wins[i];
            if (!w.normalWindow && (w.tooltip || w.popupWindow) && w.resourceClass === "plasmashell") {
                const fg = w.frameGeometry;
                if (pos.x >= fg.x && pos.x < (fg.x + fg.width) &&
                    pos.y >= fg.y && pos.y < (fg.y + fg.height)) {
                    return true;
                }
            }
        }
        return false;
    }

    Timer {
        id: showTimer
        interval: 500
        repeat: false
        onTriggered: {
            if (root.currentIds.length > 0) {
                root.elevateSmallWindows(root.currentIds);
                root.highlight(root.currentIds);
            }
        }
    }

    Timer {
        id: clearTimer
        interval: 300
        repeat: false
        onTriggered: {
            if (root.currentIds.length === 0) {
                if (!root.isInsidePopup(Workspace.cursorPos, Workspace.windows)) {
                    root.restoreElevated();
                    root.highlight([]);
                }
            }
        }
    }

    function checkHover() {
        const pos = Workspace.cursorPos;
        const wins = Workspace.windows;
        const matchedClasses = {};
        const matchedIds = [];

        // 1. Descobre qual ícone (resourceClass) está sob o cursor
        for (let i = 0; i < wins.length; i++) {
            const w = wins[i];
            if (!w.normalWindow) continue;
            const g = w.iconGeometry;
            if (g && g.width > 0 && g.height > 0) {
                if (pos.x >= g.x && pos.x < (g.x + g.width) &&
                    pos.y >= g.y && pos.y < (g.y + g.height)) {
                    if (w.resourceClass) {
                        matchedClasses[String(w.resourceClass)] = true;
                    }
                }
            }
        }

        // 2. Inclui TODAS as janelas abertas daquele aplicativo
        for (let i = 0; i < wins.length; i++) {
            const w = wins[i];
            if (!w.normalWindow) continue;
            if (w.resourceClass && matchedClasses[String(w.resourceClass)]) {
                matchedIds.push(String(w.internalId));
            }
        }

        const newKey = matchedIds.join(",");
        if (newKey !== root.currentKey) {
            if (matchedIds.length === 0) {
                showTimer.stop();
                root.currentKey = "";
                root.currentIds = [];
                if (root.isInsidePopup(pos, wins)) {
                    clearTimer.stop();
                    return;
                }
                clearTimer.restart();
            } else {
                clearTimer.stop();
                root.currentKey = newKey;
                root.currentIds = matchedIds;
                showTimer.restart();
            }
        }
    }

    Connections {
        target: Workspace
        function onCursorPosChanged() {
            root.checkHover();
        }
    }
}

# KDE Taskbar Hover Peek

A lightweight **KWin Script for KDE Plasma 6 (Wayland & X11)** that brings instant full-window preview ("Aero Peek" style) when hovering **directly over taskbar icons**—without requiring you to move the cursor up onto the thumbnail popup first.

## Why?
By default in KDE Plasma, enabling *"Hide other windows when hovering over previews"* (`highlightWindows`) only highlights a window after you hover the taskbar icon, wait for the thumbnail popup to appear, and then move your cursor up into the thumbnail preview. Furthermore, hovering a grouped task cancels any active highlight, and multi-window apps (like Steam with Library + Friends List + Chat) often obscure smaller windows behind the main window.

**KDE Taskbar Hover Peek** solves all of this natively inside KWin:
- **Direct Icon Hover:** Simply rest your cursor on any taskbar icon for `500ms` to bring its window(s) into view on screen, and smoothly restore after `300ms` when leaving.
- **Multi-Window Smart Stacking:** When hovering an app with multiple open windows (e.g., **Steam** with Library, Friends List, and Chat open at the same time), all windows are shown simultaneously in their original positions while smaller windows are automatically elevated above the largest window so they are never hidden behind it.
- **Seamless Thumbnail Handoff:** Moving your cursor from the icon into the thumbnail popup seamlessly hands control over to Plasma's native per-window preview.
- **Live Reloading (No Logout Needed):** Includes a `reload-peek` CLI helper that bypasses KWin's session QML cache so you can tweak delay intervals and apply changes instantly.

---

## Installation

Requirements: **KDE Plasma 6** (`kwin`, `kwriteconfig6`, `qdbus6`).

```bash
git clone https://github.com/SuicinivArievilo/Linux-KDE-Arch.git
cd Linux-KDE-Arch
chmod +x install.sh uninstall.sh reload-peek
./install.sh
```

---

## Customizing Hover Delays

1. Open `~/.config/taskbarhoverpeek.qml` in any text editor.
2. Adjust the timer intervals (in milliseconds):
   - `showTimer` (`interval: 500`): Delay before showing windows when hovering an icon.
   - `clearTimer` (`interval: 300`): Delay before restoring windows when the cursor leaves the icon.
3. Apply changes immediately without logging out:
   ```bash
   reload-peek
   ```

---

## Uninstallation

```bash
./uninstall.sh
```

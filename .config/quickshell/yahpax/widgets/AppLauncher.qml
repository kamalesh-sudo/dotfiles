import QtQuick
import Quickshell
import Quickshell.Io
import "../core" as Core

// Thin IPC entry point — the actual launcher UI lives inside
// BarMorph.qml (the bar grows into the launcher panel). This file
// only exists so `qs -p ~/.config/quickshell/yahpax ipc call appLauncher toggle` works
// from outside (e.g. a Hyprland keybind).
Item {
    IpcHandler {
        target: "appLauncher"
        function toggle(): void { Core.AppState.requestMorph("launcher"); }
        function open(): void { Core.AppState.requestMorph("launcher"); }
        function close(): void { Core.AppState.closeMorph(); }
    }
}

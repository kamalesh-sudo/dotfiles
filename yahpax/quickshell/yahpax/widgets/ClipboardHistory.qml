import QtQuick
import Quickshell
import Quickshell.Io
import "../core" as Core
// Thin IPC entry point — the actual clipboard UI lives insid
// toggle` works from a keybind.
Item {
    IpcHandler {
        target: "clipboardHistory"
        function toggle(): void { Core.AppState.requestMorph("clipboard"); }
        function open(): void { Core.AppState.requestMorph("clipboard"); }
        function close(): void { Core.AppState.closeMorph(); }
    }
}


import QtQuick
import Quickshell
import Quickshell.Io
import "../core" as Core

// IPC-only bridge, matching Caelestia's separation between the clipboard
// service and the surface that displays it.
Item {
    IpcHandler {
        target: "clipboardHistory"
        function toggle(): void { Core.AppState.requestMorph("clipboard"); }
        function open(): void { Core.AppState.requestMorph("clipboard"); }
        function close(): void { Core.AppState.closeMorph(); }
    }
}

import QtQuick
import Quickshell
import Quickshell.Io
import "../core" as Core

Item {
    IpcHandler {
        target: "bluetoothMenu"
        function toggle(): void {
            if (Core.AppState.barMorph === "bluetooth")
                Core.AppState.closeMorph()
            else
                Core.AppState.requestMorph("bluetooth")
        }
        function open(): void { Core.AppState.requestMorph("bluetooth") }
        function close(): void { Core.AppState.closeMorph() }
    }
}

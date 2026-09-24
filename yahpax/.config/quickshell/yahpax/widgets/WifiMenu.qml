import QtQuick
import Quickshell
import Quickshell.Io
import "../core" as Core

Item {
    IpcHandler {
        target: "wifiMenu"
        function toggle(): void {
            if (Core.AppState.barMorph === "wifi")
                Core.AppState.closeMorph();
            else
                Core.AppState.requestMorph("wifi");
        }
        function open(): void { Core.AppState.requestMorph("wifi"); }
        function close(): void { Core.AppState.closeMorph(); }
    }
}

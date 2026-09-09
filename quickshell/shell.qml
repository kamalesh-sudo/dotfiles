import Quickshell
import Quickshell.Io
import QtQuick
import "core" as Core
import "widgets"
import "audioframe"

ShellRoot {
    Bar {}
    BarMorph {}
    WallpaperSelector {}
    ClipboardHistory {}
    AppLauncher {}
    NotificationService {}
    NotificationPopup {}
    WifiMenu {}
    ArchSymbol{}
    Dock{}
    TodoBoard{}
    Variants {

        model: Quickshell.screens

        AudioFrameWindow {

            required property var modelData

            targetScreen: modelData
        }
    }

    IpcHandler {
        target: "powerMenu"
        function toggle(): void { Core.AppState.requestMorph("power") }
        function open(): void { Core.AppState.requestMorph("power") }
        function close(): void { Core.AppState.closeMorph() }
        function lock(): void { Core.AppState.runPowerAction("lock") }
        function suspend(): void { Core.AppState.runPowerAction("sleep") }
        function reboot(): void { Core.AppState.runPowerAction("reboot") }
        function poweroff(): void { Core.AppState.runPowerAction("shutdown") }
    }

}

import Quickshell
import Quickshell.Io
import QtQuick
import "core" as Core
import "widgets"

ShellRoot {
    // Start the single clipboard backend with the shell, not only after the
    // Clipboard Menu is opened.
    Component.onCompleted: Core.ClipboardService.start()

    GlobalShellLayer {}
    WallpaperSelector {}
    ClipboardHistory {}
    AppLauncher {}
    NotificationService {}
    WifiMenu {}
    BluetoothMenu {}
    IpcHandler {
        target: "powerMenu"
        function toggle(): void { Core.AppState.togglePowerMenu() }
        function open(): void { Core.AppState.openPowerMenu() }
        function close(): void { Core.AppState.closePowerMenu() }
        function lock(): void { Core.AppState.runPowerAction("lock") }
        function suspend(): void { Core.AppState.runPowerAction("sleep") }
        function reboot(): void { Core.AppState.runPowerAction("reboot") }
        function poweroff(): void { Core.AppState.runPowerAction("shutdown") }
    }

}

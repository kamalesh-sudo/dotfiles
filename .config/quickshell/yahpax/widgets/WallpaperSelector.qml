import Quickshell
import Quickshell.Io
import QtQuick
import "../core" as Core

// IPC bridge for the wallpaper mode rendered by BarMorph.
Item {
    IpcHandler {
        target: "wallpaperSelector"

        function toggle(): void {
            Core.AppState.requestMorph("wallpaper");
        }

        function open(): void {
            Core.AppState.requestMorph("wallpaper");
        }

        function close(): void {
            Core.AppState.closeMorph();
        }
    }
}

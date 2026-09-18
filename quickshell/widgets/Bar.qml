import Quickshell
import Quickshell.Wayland
import QtQuick
import "../core" as Core

// The sole layer-shell surface for the bar and Dynamic Island. Its geometry
// is fixed; only the BarMorph child changes size inside it.
Variants {
    model: Quickshell.screens

    PanelWindow {
        id: window
        required property var modelData
        screen: modelData

        readonly property real barHeight: Core.Colors.barHeight + 3
        readonly property real fixedWidth: Math.max(Math.min(880, modelData.width * 0.300), 900)
        readonly property real fixedHeight: barHeight + 380
        readonly property bool focusedFullscreen: ToplevelManager.activeToplevel?.fullscreen === true

        anchors.top: true
        implicitWidth: fixedWidth
        implicitHeight: fixedHeight
        exclusiveZone: barHeight
        exclusionMode: ExclusionMode.Normal
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: Core.MenuStyle.namespace
        WlrLayershell.keyboardFocus: morph.expanded
            ? WlrKeyboardFocus.Exclusive
            : WlrKeyboardFocus.None
        // Fullscreen is read from the active Wayland toplevel. Keeping the
        // existing window/mask architecture means IPC keybinds still work,
        // while no visual or pointer surface remains during fullscreen.
        visible: !focusedFullscreen && (Core.AppState.showBar || morph.expanded)
        mask: Region {
            item: morph
        }

        Rectangle {
            width: window.fixedWidth
            height: window.fixedHeight
            implicitWidth: window.fixedWidth
            implicitHeight: window.fixedHeight
            color: Qt.rgba(0, 0, 0, 0.001)
        }

        BarMorph {
            id: morph
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            modelData: window.modelData
            normalWidth: Math.min(880, window.modelData.width * 0.300)
            normalHeight: window.barHeight
        }
    }
}

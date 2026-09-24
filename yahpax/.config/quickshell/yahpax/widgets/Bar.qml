import Quickshell
import Quickshell.Wayland
import QtQuick
import "../core" as Core

// The sole layer-shell surface for the bar and Dynamic Island. Its geometry
// is fixed; only the BarMorph child changes size inside it.
Item {
    id: window
    required property var modelData
    property Item inputItem: morph
    property Item revealInput: revealZone
    property real shellJoinRadius: morph.visualRadius

        readonly property real barHeight: Core.Colors.barHeight + 3
        readonly property real fixedWidth: Math.max(Math.min(880, modelData.width * 0.300), 900)
        readonly property real fixedHeight: barHeight + 380
        readonly property bool focusedFullscreen: ToplevelManager.activeToplevel?.fullscreen === true
        readonly property bool noWindows: ToplevelManager.activeToplevel === null
        readonly property bool contentVisible: !focusedFullscreen
            && (noWindows || revealZone.containsMouse || barHover.hovered || morph.expanded)

        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.horizontalCenter: parent.horizontalCenter
        width: fixedWidth
        height: fixedHeight
        // Keep this host alive for the top-edge reveal zone even while the
        // visible bar is hidden. The visual BarMorph is controlled separately.
        visible: !focusedFullscreen
        MouseArea {
            id: revealZone
            x: 0
            y: -5
            width: window.fixedWidth
            height: 10
            z: 100
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
        }
        HoverHandler {
            id: barHover
            parent: morph
            enabled: morph.visible
        }
        BarMorph {
            id: morph
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            modelData: window.modelData
            normalWidth: Math.min(880, window.modelData.width * 0.300)
            normalHeight: window.barHeight
            visible: window.contentVisible
        }
}

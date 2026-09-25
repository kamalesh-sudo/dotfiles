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
    // The shell uses this to request keyboard focus only while a selector is open.
    readonly property bool expanded: morph.expanded

        readonly property real barHeight: Core.MenuStyle.bar.baseHeight + Core.MenuStyle.bar.heightExtra
        readonly property real fixedWidth: Math.max(Math.min(Core.MenuStyle.bar.hostMaxWidth, modelData.width * Core.MenuStyle.bar.collapsedWidthRatio), Core.MenuStyle.bar.hostMinWidth)
        readonly property real fixedHeight: barHeight + Core.MenuStyle.bar.hostHeightExtra
        readonly property bool focusedFullscreen: ToplevelManager.activeToplevel?.fullscreen === true
        readonly property bool noWindows: ToplevelManager.activeToplevel === null
        readonly property bool revealTarget: !focusedFullscreen
            && (noWindows || revealZone.containsMouse || barHover.hovered || morph.expanded)
        property real revealProgress: revealTarget ? 1 : 0
        readonly property bool contentVisible: revealProgress > Core.MenuStyle.input.visibleThreshold

        // Match Caelestia's Dashboard edge reveal: FastSpatial, 350 ms,
        // with no separate hover delay.
        Behavior on revealProgress {
            NumberAnimation {
                duration: Core.MenuStyle.expressiveFastSpatialDuration
                easing.type: Core.MenuStyle.bezierSplineType
                easing.bezierCurve: Core.MenuStyle.fastSpatialCurve
            }
        }

        anchors.top: parent.top
        anchors.topMargin: Core.MenuStyle.layout.barTopOffset
        anchors.horizontalCenter: parent.horizontalCenter
        width: fixedWidth
        height: fixedHeight
        // Keep this host alive for the top-edge reveal zone even while the
        // visible bar is hidden. The visual BarMorph is controlled separately.
        visible: !focusedFullscreen
        MouseArea {
            id: revealZone
            x: (window.fixedWidth - width) / 2
            y: Core.MenuStyle.bar.revealZoneOffset
            width: window.fixedWidth * Core.MenuStyle.bar.revealZoneWidthRatio
            height: Core.MenuStyle.bar.revealZoneHeight
            z: Core.MenuStyle.input.revealZoneZ
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
            normalWidth: Math.min(Core.MenuStyle.bar.collapsedWidthMax, window.modelData.width * Core.MenuStyle.bar.collapsedWidthRatio)
            normalHeight: window.barHeight
            visible: window.contentVisible
            opacity: window.revealProgress
        }
}

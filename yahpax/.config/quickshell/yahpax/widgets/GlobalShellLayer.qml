import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import "../core" as Core
import "../audioframe"

// One Caelestia-style screen surface for Yahpax. Visual components are
// children of this coordinate space; the Region below is the only input mask.
Variants {
    model: Quickshell.screens

    PanelWindow {
        id: root
        required property var modelData
        screen: modelData

        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        anchors.right: true
        implicitWidth: modelData.width
        implicitHeight: modelData.height
        color: "transparent"
        visible: true
        readonly property color globalSurfaceColor: Core.MenuStyle.globalSurfaceColor
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: Core.MenuStyle.namespace
        exclusionMode: ExclusionMode.Ignore

        mask: Region {
            Region { item: bar.revealInput }
            Region { item: bar.inputItem }
            Region { item: power.inputItem }
            Region { item: dock }
            Region { item: todoBoard.inputItem }
            Region { item: notifications.inputItem }
        }

        // The layer itself is full-screen; this anchored border is the exact
        // globalEdgeThickness perimeter on every edge and has no input of its own.
        Rectangle {
            id: edgeStrip
            anchors.fill: parent
            color: "transparent"
            radius: Core.MenuStyle.sharedRadius.panel
            border.width: Core.MenuStyle.globalEdgeThickness
            border.color: root.globalSurfaceColor
            z: 10
            antialiasing: true
            layer.enabled: true
            layer.smooth: true
        }

        // Caelestia uses one BlobInvertedRect/BlobRect surface in its
        // full-screen window. This Shape is the Yahpax-native equivalent:
        // one continuous path joins the full-width shell edge to BarMorph,
        // so there is no stacked connector, seam, or second border.
        Shape {
            id: shellSurface
            anchors.fill: parent
            visible: bar.contentVisible
            antialiasing: true
            layer.enabled: true
            layer.smooth: true

            readonly property real barLeft: bar.x + bar.inputItem.x
            readonly property real barRight: barLeft + bar.inputItem.width
            readonly property real barTop: bar.y + bar.inputItem.y
            readonly property real barBottom: barTop + bar.inputItem.height
            // Keep the global surface intrusion equal to the global edge as the
            // perimeter. The BarMorph remains at its existing coordinates.
            readonly property real joinY: Core.MenuStyle.globalEdgeThickness
            readonly property real bottomRadius: Math.min(bar.shellJoinRadius, bar.inputItem.height / 2)

            ShapePath {
                fillColor: root.globalSurfaceColor
                strokeColor: Core.MenuStyle.globalBorderColor
                strokeWidth: Core.MenuStyle.sharedRadius.border
                joinStyle: ShapePath.RoundJoin
                capStyle: ShapePath.RoundCap

                PathMove { x: 0; y: 0 }
                PathLine { x: shellSurface.width; y: 0 }
                PathLine { x: shellSurface.width; y: shellSurface.joinY }
                PathLine { x: shellSurface.barRight; y: shellSurface.joinY }
                PathLine { x: shellSurface.barRight; y: shellSurface.barBottom - shellSurface.bottomRadius }
                PathQuad {
                    controlX: shellSurface.barRight
                    controlY: shellSurface.barBottom
                    x: shellSurface.barRight - shellSurface.bottomRadius
                    y: shellSurface.barBottom
                }
                PathLine { x: shellSurface.barLeft + shellSurface.bottomRadius; y: shellSurface.barBottom }
                PathQuad {
                    controlX: shellSurface.barLeft
                    controlY: shellSurface.barBottom
                    x: shellSurface.barLeft
                    y: shellSurface.barBottom - shellSurface.bottomRadius
                }
                PathLine { x: shellSurface.barLeft; y: shellSurface.joinY }
                PathLine { x: 0; y: shellSurface.joinY }
                PathLine { x: 0; y: 0 }
            }
        }

        Bar {
            id: bar
            modelData: root.modelData
        }

        PowerGroup {
            id: power
            modelData: root.modelData
        }

        Dock {
            id: dock
            modelData: root.modelData
        }

        ArchSymbol {
            id: archSymbol
            modelData: root.modelData
        }

        TodoBoard {
            id: todoBoard
            modelData: root.modelData
        }

        NotificationPopup {
            id: notifications
            modelData: root.modelData
            anchors.fill: parent
        }

        AudioFrameWindow {
            targetScreen: root.modelData
        }
    }
}

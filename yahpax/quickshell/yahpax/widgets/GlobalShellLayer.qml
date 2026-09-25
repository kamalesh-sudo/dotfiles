import QtQuick
import Quickshell
import Quickshell.Wayland
import "../core" as Core
import "../audioframe"

// One Caelestia-style screen surface for Yahpax. Visual components are
// children of this coordinate space; the Region below is the only input mask.
Variants {
    model: Quickshell.screens

    Item {
        id: screenRoot
        required property var modelData

        PanelWindow {
        id: root
        required property var modelData
        modelData: screenRoot.modelData
        screen: screenRoot.modelData

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
        // Give keyboard focus to the expanded selector surface on demand.
        // The collapsed shell remains keyboard-transparent.
        // Match Caelestia's drawer model: request keyboard focus only while a
        // mode is open, then let the loaded mode claim the active focus item.
        WlrLayershell.keyboardFocus: bar.expanded
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None
        exclusionMode: ExclusionMode.Ignore

        mask: Region {
            Region { item: bar.revealInput }
            Region { item: bar.contentVisible ? bar.inputItem : null }
            Region { item: power.inputItem }
            Region { item: dock.visible ? dock : null }
            Region { item: todoBoard.inputItem }
            Region { item: notifications.inputItem }
        }

        // The PanelWindow is full-screen, but the visible cover is finite and
        // follows the existing Bar/BarMorph footprint.
        MenuPanel {
            id: shellSurface
            // Match the visible cover to the actual BarMorph instead of the
            // larger fixed host window. Keep it centered as the morph resizes.
            x: bar.x + (bar.fixedWidth - bar.inputItem.width) / 2
            y: 0
            width: bar.inputItem.width
            height: bar.y + bar.inputItem.y + bar.inputItem.height
            visible: bar.contentVisible
            opacity: bar.revealProgress
            // Collapsed bar only: a four-point tapered trapezoid. Expanded
            // BarMorph keeps MenuPanel's existing path unchanged.
            trapezoid: !bar.inputItem.expanded
            // Asymmetric reference silhouette: square top and bottom-left,
            // with matching diagonal cuts on both lower corners.
            surfaceColor: root.globalSurfaceColor
            outlineColor: Core.MenuStyle.globalBorderColor
            outlineWidth: Core.MenuStyle.sharedRadius.border
            surfaceOpacity: bar.revealProgress
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
        }
        }

    // Functional screen reservations, following Caelestia's Exclusions.qml:
    // each edge is an independent transparent layer-shell surface with an
    // exclusive zone. These surfaces have no visual border and no input.
    PanelWindow {
        screen: screenRoot.modelData
        anchors.top: true
        implicitWidth: Core.MenuStyle.layout.exclusionExtent
        implicitHeight: Core.MenuStyle.layout.exclusionExtent
        color: "transparent"
        exclusiveZone: Core.MenuStyle.globalEdgeThickness
        mask: Region {}
        WlrLayershell.namespace: "quickshell-bar-exclusion"
        WlrLayershell.layer: WlrLayer.Top
    }

    PanelWindow {
        screen: screenRoot.modelData
        anchors.bottom: true
        implicitWidth: Core.MenuStyle.layout.exclusionExtent
        implicitHeight: Core.MenuStyle.layout.exclusionExtent
        color: "transparent"
        exclusiveZone: Core.MenuStyle.globalEdgeThickness
        mask: Region {}
        WlrLayershell.namespace: "quickshell-bar-exclusion"
        WlrLayershell.layer: WlrLayer.Top
    }

    PanelWindow {
        screen: screenRoot.modelData
        anchors.left: true
        implicitWidth: Core.MenuStyle.layout.exclusionExtent
        implicitHeight: Core.MenuStyle.layout.exclusionExtent
        color: "transparent"
        exclusiveZone: Core.MenuStyle.globalEdgeThickness
        mask: Region {}
        WlrLayershell.namespace: "quickshell-bar-exclusion"
        WlrLayershell.layer: WlrLayer.Top
    }

    PanelWindow {
        screen: screenRoot.modelData
        anchors.right: true
        implicitWidth: Core.MenuStyle.layout.exclusionExtent
        implicitHeight: Core.MenuStyle.layout.exclusionExtent
        color: "transparent"
        exclusiveZone: Core.MenuStyle.globalEdgeThickness
        mask: Region {}
        WlrLayershell.namespace: "quickshell-bar-exclusion"
        WlrLayershell.layer: WlrLayer.Top
    }
    }
}

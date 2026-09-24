import QtQuick
import "../core" as Core

// Shared expanded-menu surface. Bar/Island and Notification Center both use
// this component so shape, surface, border, and clipping cannot drift.
Core.SharpShape {
    id: root

    property color surfaceColor: Core.MenuStyle.globalSurfaceColor
    property color outlineColor: Core.MenuStyle.globalBorderColor
    property real outlineWidth: Core.MenuStyle.sharedRadius.border
    property bool cutLowerCorners: true
    property real surfaceOpacity: 1

    cutBottomLeft: root.cutLowerCorners
    cutBottomRight: root.cutLowerCorners
    cutAmount: Core.MenuStyle.radius
    fillColor: root.surfaceColor
    strokeColor: root.outlineColor
    strokeWidth: root.outlineWidth
    opacity: root.surfaceOpacity
}

import QtQuick
import QtQuick.Shapes
import "." as Core

// One shared straight-line silhouette. A cut corner is represented by two
// PathLine segments; no arcs, cubic paths, or rounded joins are used.
Shape {
    id: root

    property bool cutTopLeft: false
    property bool cutTopRight: false
    property bool cutBottomLeft: false
    property bool cutBottomRight: true
    property real cutAmount: Core.MenuStyle.radius
    // When enabled, use only the four straight trapezoid points. This is
    // used by the collapsed bar; expanded surfaces retain the normal path.
    property bool trapezoid: false
    property real trapezoidInset: width * Core.MenuStyle.bar.collapsedTrapezoidInsetRatio
    property color fillColor: "transparent"
    property color strokeColor: "transparent"
    property real strokeWidth: 0

    default property alias contentData: content.data

    readonly property real topLeftCut: cutTopLeft ? Math.min(cutAmount, width / 2, height / 2) : 0
    readonly property real topRightCut: cutTopRight ? Math.min(cutAmount, width / 2, height / 2) : 0
    readonly property real bottomLeftCut: cutBottomLeft ? Math.min(cutAmount, width / 2, height / 2) : 0
    readonly property real bottomRightCut: cutBottomRight ? Math.min(cutAmount, width / 2, height / 2) : 0
    // Keep the complete stroke inside the clipped item. A Shape stroke is
    // centered on its path; placing the path on x/y=0 clipped half of the
    // left edge (and similarly affected the other outer edges).
    readonly property real strokeInset: Math.max(0, strokeWidth / 2)
    readonly property real pathLeft: strokeInset
    readonly property real pathTop: strokeInset
    readonly property real pathRight: Math.max(pathLeft, width - strokeInset)
    readonly property real pathBottom: Math.max(pathTop, height - strokeInset)
    readonly property real pathWidth: Math.max(0, pathRight - pathLeft)
    readonly property real pathHeight: Math.max(0, pathBottom - pathTop)
    readonly property real pathTopLeftCut: cutTopLeft ? Math.min(cutAmount, pathWidth / 2, pathHeight / 2) : 0
    readonly property real pathTopRightCut: cutTopRight ? Math.min(cutAmount, pathWidth / 2, pathHeight / 2) : 0
    readonly property real pathBottomLeftCut: cutBottomLeft ? Math.min(cutAmount, pathWidth / 2, pathHeight / 2) : 0
    readonly property real pathBottomRightCut: cutBottomRight ? Math.min(cutAmount, pathWidth / 2, pathHeight / 2) : 0

    Behavior on cutAmount {
        NumberAnimation {
            duration: Core.MenuStyle.menuTransition.expandDuration
            easing.type: Core.MenuStyle.bezierSplineType
            easing.bezierCurve: Core.MenuStyle.menuTransition.expandEasing
        }
    }

    antialiasing: true
    clip: true
    layer.enabled: true
    layer.smooth: true

    ShapePath {
        id: regularPath
        fillColor: root.trapezoid ? "transparent" : root.fillColor
        strokeColor: root.trapezoid ? "transparent" : root.strokeColor
        strokeWidth: root.trapezoid ? 0 : root.strokeWidth
        joinStyle: ShapePath.MiterJoin
        capStyle: ShapePath.FlatCap

        PathMove { x: root.pathLeft + root.pathTopLeftCut; y: root.pathTop }
        PathLine { x: root.pathRight - root.pathTopRightCut; y: root.pathTop }
        PathLine { x: root.pathRight; y: root.pathTop + root.pathTopRightCut }
        PathLine { x: root.pathRight; y: root.pathBottom - root.pathBottomRightCut }
        PathLine { x: root.pathRight - root.pathBottomRightCut; y: root.pathBottom }
        PathLine { x: root.pathLeft + root.pathBottomLeftCut; y: root.pathBottom }
        PathLine { x: root.pathLeft; y: root.pathBottom - root.pathBottomLeftCut }
        PathLine { x: root.pathLeft; y: root.pathTop + root.pathTopLeftCut }
        PathLine { x: root.pathLeft + root.pathTopLeftCut; y: root.pathTop }
    }

    // Collapsed bar silhouette: A -> B -> C -> D -> A. There are no
    // vertical side segments and no independent corner-cut segments.
    ShapePath {
        id: trapezoidPath
        readonly property real inset: Math.min(root.trapezoidInset, root.pathWidth / 2)
        fillColor: root.trapezoid ? root.fillColor : "transparent"
        strokeColor: root.trapezoid ? root.strokeColor : "transparent"
        strokeWidth: root.trapezoid ? root.strokeWidth : 0
        joinStyle: ShapePath.MiterJoin
        capStyle: ShapePath.FlatCap

        PathMove { x: root.pathLeft; y: root.pathTop }
        PathLine { x: root.pathRight; y: root.pathTop }
        PathLine { x: root.pathRight - trapezoidPath.inset; y: root.pathBottom }
        PathLine { x: root.pathLeft + trapezoidPath.inset; y: root.pathBottom }
        PathLine { x: root.pathLeft; y: root.pathTop }
    }

    Item {
        id: content
        anchors.fill: parent
    }
}

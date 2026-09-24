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
    property color fillColor: "transparent"
    property color strokeColor: "transparent"
    property real strokeWidth: 0

    default property alias contentData: content.data

    readonly property real topLeftCut: cutTopLeft ? Math.min(cutAmount, width / 2, height / 2) : 0
    readonly property real topRightCut: cutTopRight ? Math.min(cutAmount, width / 2, height / 2) : 0
    readonly property real bottomLeftCut: cutBottomLeft ? Math.min(cutAmount, width / 2, height / 2) : 0
    readonly property real bottomRightCut: cutBottomRight ? Math.min(cutAmount, width / 2, height / 2) : 0

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
        fillColor: root.fillColor
        strokeColor: root.strokeColor
        strokeWidth: root.strokeWidth
        joinStyle: ShapePath.MiterJoin
        capStyle: ShapePath.FlatCap

        PathMove { x: root.topLeftCut; y: 0 }
        PathLine { x: root.width - root.topRightCut; y: 0 }
        PathLine { x: root.width; y: root.topRightCut }
        PathLine { x: root.width; y: root.height - root.bottomRightCut }
        PathLine { x: root.width - root.bottomRightCut; y: root.height }
        PathLine { x: root.bottomLeftCut; y: root.height }
        PathLine { x: 0; y: root.height - root.bottomLeftCut }
        PathLine { x: 0; y: root.topLeftCut }
        PathLine { x: root.topLeftCut; y: 0 }
    }

    Item {
        id: content
        anchors.fill: parent
    }
}

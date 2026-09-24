import QtQuick
import QtQuick.Shapes

// One canonical quarter-round. Rotate this component for each corner rather
// than maintaining separate top/bottom/left/right curve implementations.
Shape {
    id: root

    property real radius: 16
    property color fillColor: "transparent"
    property color strokeColor: "transparent"
    property real strokeWidth: 0

    // 0 = top-left, 1 = top-right, 2 = bottom-right, 3 = bottom-left.
    property int orientation: 0

    width: radius
    height: radius
    rotation: orientation * 90
    transformOrigin: Item.Center
    antialiasing: true
    layer.enabled: true
    layer.smooth: true

    ShapePath {
        fillColor: root.fillColor
        strokeColor: "transparent"
        strokeWidth: 0

        PathMove { x: root.radius; y: 0 }
        PathLine { x: 0; y: 0 }
        PathLine { x: 0; y: root.radius }
        PathArc {
            x: root.radius
            y: 0
            radiusX: root.radius
            radiusY: root.radius
            useLargeArc: false
            // Inverted canonical curve: the arc opens toward the corner
            // instead of away from it.
            direction: PathArc.Clockwise
        }
    }

    ShapePath {
        fillColor: "transparent"
        strokeColor: root.strokeColor
        strokeWidth: root.strokeWidth
        capStyle: ShapePath.RoundCap

        PathMove { x: root.radius; y: 0 }
        PathArc {
            x: 0
            y: root.radius
            radiusX: root.radius
            radiusY: root.radius
            useLargeArc: false
            direction: PathArc.Counterclockwise
        }
    }
}

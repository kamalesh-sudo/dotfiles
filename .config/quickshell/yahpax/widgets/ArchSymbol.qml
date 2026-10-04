import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Shapes
import "../core" as Core

Item {
    property var modelData

        anchors.top: parent.top
        anchors.left: parent.left

        anchors.topMargin: 92
        anchors.leftMargin: 72

        width: 190
        height: 210

        visible: Core.AppState.showDesktopWidgets && ToplevelManager.activeToplevel === null

        Item {
            anchors.fill: parent

            // =========================================================
            // OUTER HOLOGRAPHIC TRIANGLE
            // =========================================================

            Shape {
                id: outerTriangle

                anchors.centerIn: parent

                width: 178
                height: 178

                ShapePath {
                    fillColor: "transparent"

                    strokeColor: Qt.rgba(
                        Core.Colors.borderColor.r,
                        Core.Colors.borderColor.g,
                        Core.Colors.borderColor.b,
                        0.20
                    )

                    strokeWidth: 1

                    joinStyle: ShapePath.RoundJoin
                    capStyle: ShapePath.RoundCap

                    PathSvg {
                        path: "
                            M 89 4
                            L 7 166
                            L 171 166
                            Z
                        "
        }
}
}

                SequentialAnimation on opacity {
                    loops: Animation.Infinite

                    NumberAnimation {
                        to: 0.35
                        duration: 2200
                        easing.type: Easing.InOutSine
                    }

                    NumberAnimation {
                        to: 0.75
                        duration: 2200
                        easing.type: Easing.InOutSine
                    }
                }
            }

            // =========================================================
            // INNER TRIANGLE
            // =========================================================

            Shape {
                anchors.centerIn: parent

                width: 158
                height: 158

                ShapePath {
                    fillColor: "transparent"

                    strokeColor: Qt.rgba(
                        Core.Colors.accent2.r,
                        Core.Colors.accent2.g,
                        Core.Colors.accent2.b,
                        0.18
                    )

                    strokeWidth: 0.8

                    joinStyle: ShapePath.RoundJoin
                    capStyle: ShapePath.RoundCap

                    PathSvg {
                        path: "
                            M 79 12
                            L 14 150
                            L 144 150
                            Z
                        "
                    }
                }

                SequentialAnimation on opacity {
                    loops: Animation.Infinite

                    NumberAnimation {
                        to: 0.08
                        duration: 1700
                    }

                    NumberAnimation {
                        to: 0.45
                        duration: 1700
                    }
                }
            }

            // =========================================================
            // ARCH OUTLINE
            // =========================================================

            Shape {
                id: arch

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top

                anchors.topMargin: 12

                width: 150
                height: 150

                ShapePath {
                    fillColor: Qt.rgba(
                        Core.Colors.borderColor.r,
                        Core.Colors.borderColor.g,
                        Core.Colors.borderColor.b,
                        0.025
                    )

                    strokeColor: Core.Colors.borderColor

                    strokeWidth: 1.7

                    joinStyle: ShapePath.RoundJoin
                    capStyle: ShapePath.RoundCap

                    PathSvg {
                        path: "
                            M 75 8

                            L 12 138

                            L 48 118

                            L 75 76

                            L 102 118

                            L 138 138

                            Z
                        "
                    }
                }

                // Holographic blinking
                SequentialAnimation on opacity {
                    loops: Animation.Infinite

                    PauseAnimation {
                        duration: 300
                    }

                    NumberAnimation {
                        to: 0.35
                        duration: 180
                    }

                    NumberAnimation {
                        to: 0.90
                        duration: 160
                    }

                    NumberAnimation {
                        to: 0.48
                        duration: 220
                    }

                    NumberAnimation {
                        to: 0.82
                        duration: 180
                    }

                    NumberAnimation {
                        to: 0.28
                        duration: 500
                    }
                }
            }

            // =========================================================
            // ARCH INNER ECHO
            // =========================================================

            Shape {
                anchors.centerIn: arch

                width: 112
                height: 112

                ShapePath {
                    fillColor: "transparent"

                    strokeColor: Core.Colors.accent2

                    strokeWidth: 0.9

                    joinStyle: ShapePath.RoundJoin
                    capStyle: ShapePath.RoundCap

                    PathSvg {
                        path: "
                            M 56 10

                            L 18 92

                            L 39 80

                            L 56 52

                            L 73 80

                            L 94 92

                            Z
                        "
                    }
                }

                SequentialAnimation on opacity {
                    loops: Animation.Infinite

                    NumberAnimation {
                        to: 0.08
                        duration: 500
                    }

                    NumberAnimation {
                        to: 0.55
                        duration: 700
                    }

                    NumberAnimation {
                        to: 0.18
                        duration: 400
                    }
                }
            }

            // =========================================================
            // HOLOGRAPHIC SCAN LINE
            // =========================================================

            Rectangle {
                id: scanLine

                anchors.horizontalCenter: arch.horizontalCenter

                y: arch.y + 18

                width: 120
                height: 1

                color: Core.Colors.iconColor

                opacity: 0.0

                SequentialAnimation on y {
                    loops: Animation.Infinite

                    NumberAnimation {
                        from: arch.y + 18
                        to: arch.y + 125

                        duration: 2600

                        easing.type: Easing.Linear
                    }
                }

                SequentialAnimation on opacity {
                    loops: Animation.Infinite

                    NumberAnimation {
                        to: 0.45
                        duration: 300
                    }

                    PauseAnimation {
                        duration: 1800
                    }

                    NumberAnimation {
                        to: 0.0
                        duration: 400
                    }
                }
            }

            // =========================================================
            // CENTRAL HOLOGRAPHIC CORE
            // =========================================================

            Rectangle {
                id: core

                anchors.centerIn: arch

                width: 6
                height: 6

                radius: 3

                color: Core.Colors.iconColor

                SequentialAnimation on opacity {
                    loops: Animation.Infinite

                    NumberAnimation {
                        to: 0.25
                        duration: 500
                        easing.type: Easing.InOutSine
                    }

                    NumberAnimation {
                        to: 1.0
                        duration: 350
                        easing.type: Easing.InOutSine
                    }

                    NumberAnimation {
                        to: 0.40
                        duration: 250
                    }

                    NumberAnimation {
                        to: 0.90
                        duration: 300
                    }
                }

                SequentialAnimation on scale {
                    loops: Animation.Infinite

                    NumberAnimation {
                        to: 0.75
                        duration: 500
                        easing.type: Easing.InOutSine
                    }

                    NumberAnimation {
                        to: 1.25
                        duration: 350
                        easing.type: Easing.InOutSine
                    }

                    NumberAnimation {
                        to: 0.85
                        duration: 250
                    }

                    NumberAnimation {
                        to: 1.0
                        duration: 300
                    }
                }
            }

            // =========================================================
            // SMALL HOLOGRAPHIC NODES
            // =========================================================

            Repeater {
                model: 3

                delegate: Rectangle {
                    required property int index

                    width: 3
                    height: 3

                    radius: 1.5

                    color: index === 1
                        ? Core.Colors.accent2
                        : Core.Colors.borderColor

                    x: [
                        23,
                        93,
                        163
                    ][index]

                    y: [
                        155,
                        18,
                        155
                    ][index]

                    SequentialAnimation on opacity {
                        loops: Animation.Infinite

                        PauseAnimation {
                            duration: index * 280
                        }

                        NumberAnimation {
                            to: 0.9
                            duration: 500
                        }

                        NumberAnimation {
                            to: 0.15
                            duration: 700
                        }

                        PauseAnimation {
                            duration: 400
                        }
                    }
                }
            }

            // =========================================================
            // LABEL
            // =========================================================

            Text {
                anchors.horizontalCenter: parent.horizontalCenter

                anchors.bottom: parent.bottom

                anchors.bottomMargin: 5

                text: "// ARCH"

                color: Core.Colors.accent2

                opacity: 0.62

                font.family: Core.Colors.fontFamily
                font.pixelSize: 9
                font.letterSpacing: 3
            }
}

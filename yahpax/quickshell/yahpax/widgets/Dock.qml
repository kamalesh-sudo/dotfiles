import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import ".." as Local
import "../core" as Core

// Left-side quick-launch dock, parallelogram buttons with a liquid
// glass sheen and a pulsing bottom accent line.
Item {
    id: win
    property var modelData
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: 1
        // Desktop decoration stays visible only while no application window
        // is active, matching the shell's window-aware desktop behavior.
        visible: Local.AppState.showDesktopWidgets && ToplevelManager.activeToplevel === null

        property int btnW: 300
        property int btnH: 60

        readonly property var actions: [
            { label: "terminal",     sub: "kitty",              icon: "\uf120", cmd: ["kitty"] },
            { label: "qutebrowser",  sub: "web browser",       icon: "\ue76b", cmd: ["qutebrowser"] },
            { label: "youtube",       sub: "media",         icon: "\uf16a", cmd: ["freetube"] },
            { label: "Burp",       sub: "Proxy",         icon: "\udb84\uddea", cmd: ["burpsuite"] },
        ]

        width: btnW + 160
        height: column.implicitHeight + 30

        Column {
            id: column
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            spacing: 16

            Repeater {
                model: win.actions

                delegate: Item {
                    id: entry
                    width: win.btnW
                    height: win.btnH
                    x: index * 17
                    property bool hovered: mouse.containsMouse

                    scale: hovered ? 1.05 : 1.0
                    Behavior on scale { NumberAnimation { duration: Core.MenuStyle.sharedAnimation.fastDuration; easing.type: Core.MenuStyle.bezierSplineType; easing.bezierCurve: Core.MenuStyle.sharedAnimation.fastSpatialCurve } }

                    Rectangle {
                        id: body
                        anchors.fill: parent
                        color: entry.hovered
                            ? Qt.rgba(Local.Colors.background.r, Local.Colors.background.g,
                                      Local.Colors.background.b, 0.72)
                            : Core.MenuStyle.globalSurfaceColor
                        border.width: 1
                        border.color: entry.hovered
                            ? Local.Colors.accent
                            : Qt.rgba(Local.Colors.accent2.r, Local.Colors.accent2.g, Local.Colors.accent2.b, 0.6)
                        transform: Matrix4x4 {
                            matrix: Qt.matrix4x4(1, 0.28, 0, -8,  0, 1, 0, 0,  0, 0, 1, 0,  0, 0, 0, 1)
                        }
                        Behavior on color { ColorAnimation { duration: Core.MenuStyle.sharedAnimation.duration; easing.type: Core.MenuStyle.bezierSplineType; easing.bezierCurve: Core.MenuStyle.sharedAnimation.defaultEffectsCurve } }
                        Behavior on color { ColorAnimation { duration: Core.MenuStyle.sharedAnimation.duration; easing.type: Core.MenuStyle.bezierSplineType; easing.bezierCurve: Core.MenuStyle.sharedAnimation.defaultEffectsCurve } }
                        Behavior on border.color { ColorAnimation { duration: Core.MenuStyle.sharedAnimation.duration; easing.type: Core.MenuStyle.bezierSplineType; easing.bezierCurve: Core.MenuStyle.sharedAnimation.defaultEffectsCurve } }

                        Rectangle {
                            anchors { top: parent.top; left: parent.left; right: parent.right }
                            height: 1
                            color: "#55ffffff"
                        }
                        Rectangle {
                            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                            height: 2
                            color: Local.Colors.accent
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { to: 1.0;  duration: 1100; easing.type: Easing.InOutSine }
                                NumberAnimation { to: 0.35; duration: 1100; easing.type: Easing.InOutSine }
                            }
                        }
                    }

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 24
                        spacing: 13

                        Rectangle {
                            width: 36; height: 34
                            anchors.verticalCenter: parent.verticalCenter
                            color: Qt.rgba(Local.Colors.accent.r, Local.Colors.accent.g,
                                           Local.Colors.accent.b, entry.hovered ? 0.28 : 0.14)
                            border.width: 1
                            border.color: Local.Colors.accent
                            Behavior on color { ColorAnimation { duration: Core.MenuStyle.sharedAnimation.duration; easing.type: Core.MenuStyle.bezierSplineType; easing.bezierCurve: Core.MenuStyle.sharedAnimation.defaultEffectsCurve } }

                            Text {
                                anchors.centerIn: parent
                                text: modelData.icon
                                color: Local.Colors.accent
                                font.pixelSize: 18
                                font.family: Local.Colors.fontFamily
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1
                            Text {
                                text: modelData.label
                                color: entry.hovered ? Local.Colors.accent : Local.Colors.foreground
                                font.pixelSize: 15
                                font.bold: entry.hovered
                                font.family: Local.Colors.fontFamily
                                Behavior on color { ColorAnimation { duration: Core.MenuStyle.sharedAnimation.duration; easing.type: Core.MenuStyle.bezierSplineType; easing.bezierCurve: Core.MenuStyle.sharedAnimation.defaultEffectsCurve } }
                            }
                            Text {
                                text: "› " + modelData.sub
                                color: Local.Colors.muted
                                font.pixelSize: 10
                                font.family: Local.Colors.fontFamily
                            }
                        }
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        text: "0x0" + (index + 1)
                        color: Local.Colors.accent2
                        font.pixelSize: 10
                        font.family: Local.Colors.fontFamily
                        opacity: entry.hovered ? 1.0 : 0.5
                        Behavior on opacity { NumberAnimation { duration: Core.MenuStyle.sharedAnimation.duration; easing.type: Core.MenuStyle.bezierSplineType; easing.bezierCurve: Core.MenuStyle.sharedAnimation.defaultEffectsCurve } }
                    }

                    MouseArea {
                        id: mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Quickshell.execDetached(modelData.cmd)
                    }
                }
            }
}
}

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
        anchors.leftMargin: Core.MenuStyle.dock.screenInset
        // Desktop decoration stays visible only while no application window
        // is active, matching the shell's window-aware desktop behavior.
        visible: Local.AppState.showDesktopWidgets && ToplevelManager.activeToplevel === null

        property int btnW: Core.MenuStyle.dock.buttonWidth
        property int btnH: Core.MenuStyle.dock.buttonHeight

        readonly property var actions: [
            { label: "terminal",     sub: "kitty",              icon: "\uf120", cmd: ["kitty"] },
            { label: "qutebrowser",  sub: "web browser",       icon: "\ue76b", cmd: ["qutebrowser"] },
            { label: "youtube",       sub: "media",         icon: "\uf16a", cmd: ["freetube"] },
            { label: "Burp",       sub: "Proxy",         icon: "\udb84\uddea", cmd: ["burpsuite"] },
        ]

        width: btnW + Core.MenuStyle.dock.widthExtra
        height: column.implicitHeight + Core.MenuStyle.dock.heightExtra

        Column {
            id: column
            anchors.left: parent.left
                    anchors.leftMargin: Core.MenuStyle.dock.contentLeftPadding
            anchors.verticalCenter: parent.verticalCenter
                    spacing: Core.MenuStyle.dock.entrySpacing

            Repeater {
                model: win.actions

                delegate: Item {
                    id: entry
                    width: win.btnW
                    height: win.btnH
                    x: index * Core.MenuStyle.dock.staggerOffset
                    property bool hovered: mouse.containsMouse

                    scale: hovered ? Core.MenuStyle.dock.hoverScale : Core.MenuStyle.sharedOpacity.idle
                    Behavior on scale { NumberAnimation { duration: Core.MenuStyle.sharedAnimation.fastDuration; easing.type: Core.MenuStyle.bezierSplineType; easing.bezierCurve: Core.MenuStyle.sharedAnimation.fastSpatialCurve } }

                    Rectangle {
                        id: body
                        anchors.fill: parent
                        color: entry.hovered ? Local.Colors.widgetHover : Core.MenuStyle.globalSurfaceColor
                        border.width: Core.MenuStyle.dock.entryBorderWidth
                        border.color: entry.hovered
                            ? Local.Colors.accent
                            : Local.Colors.separator
                        transform: Matrix4x4 {
                            matrix: Qt.matrix4x4(1, 0.28, 0, -8,  0, 1, 0, 0,  0, 0, 1, 0,  0, 0, 0, 1)
                        }
                        Behavior on color { ColorAnimation { duration: Core.MenuStyle.sharedAnimation.duration; easing.type: Core.MenuStyle.bezierSplineType; easing.bezierCurve: Core.MenuStyle.sharedAnimation.defaultEffectsCurve } }
                        Behavior on color { ColorAnimation { duration: Core.MenuStyle.sharedAnimation.duration; easing.type: Core.MenuStyle.bezierSplineType; easing.bezierCurve: Core.MenuStyle.sharedAnimation.defaultEffectsCurve } }
                        Behavior on border.color { ColorAnimation { duration: Core.MenuStyle.sharedAnimation.duration; easing.type: Core.MenuStyle.bezierSplineType; easing.bezierCurve: Core.MenuStyle.sharedAnimation.defaultEffectsCurve } }

                        Rectangle {
                            anchors { top: parent.top; left: parent.left; right: parent.right }
                            height: Core.MenuStyle.borderWidth
                            color: Local.Colors.separatorOverlay
                        }
                        Rectangle {
                            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                            height: Core.MenuStyle.dock.entryBorderWidth + Core.MenuStyle.borderWidth
                            color: Local.Colors.accent
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { to: Core.MenuStyle.sharedOpacity.idle;  duration: Core.MenuStyle.dock.pulseDuration; easing.type: Easing.InOutSine }
                                NumberAnimation { to: 0.35; duration: Core.MenuStyle.dock.pulseDuration; easing.type: Easing.InOutSine }
                            }
                        }
                    }

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: Core.MenuStyle.dock.rowLeftPadding
                        spacing: Core.MenuStyle.dock.rowSpacing

                        Rectangle {
                        width: Core.MenuStyle.dock.iconWidth; height: Core.MenuStyle.dock.iconHeight
                            anchors.verticalCenter: parent.verticalCenter
                            color: entry.hovered ? Local.Colors.accentSoftSurface : Local.Colors.accentFaintSurface
                            border.width: Core.MenuStyle.dock.entryBorderWidth
                            border.color: Local.Colors.accent
                            Behavior on color { ColorAnimation { duration: Core.MenuStyle.sharedAnimation.duration; easing.type: Core.MenuStyle.bezierSplineType; easing.bezierCurve: Core.MenuStyle.sharedAnimation.defaultEffectsCurve } }

                            Text {
                                anchors.centerIn: parent
                                text: modelData.icon
                                color: Local.Colors.accent
                                font.pixelSize: Core.MenuStyle.dock.iconFontSize
                                font.family: Local.Colors.fontFamily
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1
                            Text {
                                text: modelData.label
                                color: entry.hovered ? Local.Colors.accent : Local.Colors.foreground
                                font.pixelSize: Core.MenuStyle.dock.titleFontSize
                                font.bold: entry.hovered
                                font.family: Local.Colors.fontFamily
                                Behavior on color { ColorAnimation { duration: Core.MenuStyle.sharedAnimation.duration; easing.type: Core.MenuStyle.bezierSplineType; easing.bezierCurve: Core.MenuStyle.sharedAnimation.defaultEffectsCurve } }
                            }
                            Text {
                                text: "› " + modelData.sub
                                color: Local.Colors.muted
                                font.pixelSize: Core.MenuStyle.dock.metadataFontSize
                                font.family: Local.Colors.fontFamily
                            }
                        }
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: Core.MenuStyle.dock.indexRightPadding
                        anchors.verticalCenter: parent.verticalCenter
                        text: "0x0" + (index + 1)
                        color: Local.Colors.accent2
                        font.pixelSize: Core.MenuStyle.dock.metadataFontSize
                        font.family: Local.Colors.fontFamily
                        opacity: entry.hovered ? Core.MenuStyle.sharedOpacity.idle : Core.MenuStyle.dock.idleEntryOpacity
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

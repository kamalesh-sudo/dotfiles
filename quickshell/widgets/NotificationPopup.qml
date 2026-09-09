import Quickshell
import Quickshell.Wayland
import QtQuick
import "../core" as Core

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: win
        required property var modelData
        screen: modelData

        readonly property var notification: Core.AppState.popupNotification

        anchors.top: true
        anchors.right: true
        margins.top: 18
        margins.right: 24
        implicitWidth: 360
        implicitHeight: notification ? 148 : 0
        color: "transparent"
        visible: notification !== null && Core.AppState.notifications.length > 0

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell-notifications"
        exclusionMode: ExclusionMode.Ignore

        Rectangle {
            anchors.fill: parent
            radius: Core.MenuStyle.cardRadius
            color: Core.MenuStyle.morphPanelColor
            border.color: Core.Colors.accent
            border.width: Core.MenuStyle.borderWidth

            Column {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 5

                Row {
                    width: parent.width
                    spacing: 8

                    Text {
                        width: parent.width - dismiss.implicitWidth - 8
                        text: win.notification ? win.notification.appName : "Notification"
                        color: Core.Colors.muted
                        font.family: Core.Colors.fontFamily
                        font.pixelSize: 10
                        font.weight: Core.Colors.textWeight
                        elide: Text.ElideRight
                    }

                    Text {
                        id: dismiss
                        text: "×"
                        color: Core.Colors.accent
                        font.pixelSize: 18

                        MouseArea {
                            anchors.fill: parent
                            onClicked: if (win.notification) Core.AppState.dismissNotification(win.notification.id)
                        }
                    }
                }

                Text {
                    width: parent.width
                    text: win.notification ? win.notification.summary : ""
                    color: Core.Colors.foreground
                    font.family: Core.Colors.fontFamily
                    font.pixelSize: 12
                    font.weight: Core.Colors.textWeight
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    text: win.notification ? win.notification.body : ""
                    color: Core.Colors.muted
                    font.family: Core.Colors.fontFamily
                    font.pixelSize: 10
                    font.weight: Core.Colors.textWeight
                    elide: Text.ElideRight
                    maximumLineCount: 2
                    wrapMode: Text.Wrap
                }

                Row {
                    spacing: 6

                    Repeater {
                        model: win.notification ? win.notification.actions : []

                        delegate: Rectangle {
                            width: actionLabel.implicitWidth + 16
                            height: 20
                            radius: 10
                            color: Core.MenuStyle.inputSurfaceColor
                            border.color: Core.Colors.accent
                            border.width: Core.MenuStyle.borderWidth

                            Text {
                                id: actionLabel
                                anchors.centerIn: parent
                                text: modelData.text
                                color: Core.Colors.foreground
                                font.family: Core.Colors.fontFamily
                                font.pixelSize: 9
                                font.weight: Core.Colors.textWeight
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: Core.AppState.invokeNotificationAction(win.notification.id, modelData.identifier)
                            }
                        }
                    }
                }
            }
        }
    }
}

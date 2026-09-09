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
        readonly property var primaryAction: notification && notification.actions
                                             && notification.actions.length > 0
                                             ? notification.actions[0] : null

        function openNotification() {
            const current = win.notification
            if (!current) return

            if (win.primaryAction)
                Core.AppState.invokeNotificationAction(current.id, win.primaryAction.identifier)

            const desktopEntry = current.native ? current.native.desktopEntry : ""
            if (desktopEntry) Quickshell.execDetached(["gtk-launch", desktopEntry])
            Core.AppState.dismissNotification(current.id)
        }

        anchors.top: true
        anchors.right: true
        // Match the existing desktop-widget gap: bar height (56) + 36px.
        margins.top: Core.Colors.barHeight + 16 + 36
        margins.right: 28
        implicitWidth: 360
        implicitHeight: notification ? 156 : 0
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
                        width: parent.width
                        text: win.notification ? win.notification.appName : "Notification"
                        color: Core.Colors.muted
                        font.family: Core.Colors.fontFamily
                        font.pixelSize: 10
                        font.weight: Core.Colors.textWeight
                        elide: Text.ElideRight
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
                    width: parent.width
                    spacing: 6

                    Rectangle {
                        width: (parent.width - 6) / 2
                        height: 24
                        radius: Core.MenuStyle.cardRadius
                        color: closeMouse.containsMouse ? Core.MenuStyle.hoverSurfaceColor
                                                         : Core.MenuStyle.inputSurfaceColor
                        border.color: Core.Colors.accent
                        border.width: Core.MenuStyle.borderWidth

                        Text {
                            anchors.centerIn: parent
                            text: "CLOSE"
                            color: Core.Colors.foreground
                            font.family: Core.Colors.fontFamily
                            font.pixelSize: 9
                            font.weight: Core.Colors.textWeight
                        }

                        MouseArea {
                            id: closeMouse
                            anchors.fill: parent
                            onClicked: if (win.notification) Core.AppState.dismissNotification(win.notification.id)
                        }
                    }

                    Rectangle {
                        width: (parent.width - 6) / 2
                        height: 24
                        radius: Core.MenuStyle.cardRadius
                        color: openMouse.containsMouse ? Core.MenuStyle.hoverSurfaceColor
                                                        : Core.MenuStyle.inputSurfaceColor
                        border.color: Core.Colors.accent
                        border.width: Core.MenuStyle.borderWidth

                        Text {
                            anchors.centerIn: parent
                            text: win.primaryAction ? win.primaryAction.text : "OPEN"
                            color: Core.Colors.foreground
                            font.family: Core.Colors.fontFamily
                            font.pixelSize: 9
                            font.weight: Core.Colors.textWeight
                            elide: Text.ElideRight
                        }

                        MouseArea {
                            id: openMouse
                            anchors.fill: parent
                            onClicked: win.openNotification()
                        }
                    }
                }
            }
        }
    }
}

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import "../core" as Core
import ".." as Local

ColumnLayout {
    id: root
    anchors.fill: parent
    spacing: Core.MenuStyle.sharedSpacing.medium
    focus: true

    Keys.onEscapePressed: {
        Core.AppState.closeMorph()
        event.accepted = true
    }

    RowLayout {
        Layout.fillWidth: true
        Text {
            Layout.fillWidth: true
            text: "BLUETOOTH"
            color: Core.Colors.foreground
            font.family: Core.Colors.fontFamily
            font.pixelSize: 12
            font.weight: Core.Colors.titleWeight
        }
        Text {
            text: Local.BluetoothService.enabled ? "ON" : "OFF"
            color: Local.BluetoothService.enabled ? Core.Colors.accent : Core.Colors.muted
            font.family: Core.Colors.fontFamily
            font.pixelSize: 10
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Core.MenuStyle.sharedSpacing.small

        Rectangle {
            Layout.fillWidth: true
            height: 32
            radius: Core.MenuStyle.sharedRadius.card
            color: enabledMouse.pressed
                   ? Core.MenuStyle.pressedRule.accentSurface
                   : enabledMouse.containsMouse
                   ? Core.MenuStyle.toggleRule.hoverSurface
                   : Local.BluetoothService.enabled
                   ? Core.MenuStyle.toggleRule.onSurface
                   : Core.MenuStyle.toggleRule.offSurface
            border.width: Core.MenuStyle.sharedRadius.border
            border.color: Core.Colors.accent
            Behavior on color {
                ColorAnimation {
                    duration: Core.MenuStyle.toggleRule.duration
                    easing.type: Core.MenuStyle.bezierSplineType
                    easing.bezierCurve: Core.MenuStyle.sharedAnimation.fastSpatialCurve
                }
            }
            Text {
                anchors.centerIn: parent
                text: Local.BluetoothService.enabled ? "DISABLE" : "ENABLE"
                color: Core.Colors.foreground
                font.family: Core.Colors.fontFamily
                font.pixelSize: 9
            }
            MouseArea {
                id: enabledMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: Local.BluetoothService.toggleEnabled()
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 32
            radius: Core.MenuStyle.sharedRadius.card
            color: discoverMouse.pressed
                   ? Core.MenuStyle.pressedRule.accentSurface
                   : discoverMouse.containsMouse
                   ? Core.MenuStyle.hoverRule.surface
                   : Core.MenuStyle.sharedSurface.input
            border.width: Core.MenuStyle.sharedRadius.border
            border.color: Core.Colors.accent
            Behavior on color {
                ColorAnimation {
                    duration: Core.MenuStyle.hoverRule.duration
                    easing.type: Core.MenuStyle.bezierSplineType
                    easing.bezierCurve: Core.MenuStyle.sharedAnimation.fastEffectsCurve
                }
            }
            Text {
                anchors.centerIn: parent
                text: Local.BluetoothService.discovering ? "STOP SCAN" : "SCAN"
                color: Core.Colors.foreground
                font.family: Core.Colors.fontFamily
                font.pixelSize: 9
            }
            MouseArea {
                id: discoverMouse
                anchors.fill: parent
                hoverEnabled: true
                enabled: Local.BluetoothService.enabled
                onClicked: Local.BluetoothService.toggleDiscovering()
            }
        }
    }

    Text {
        Layout.fillWidth: true
        text: Local.BluetoothService.enabled
              ? Local.BluetoothService.devices.length + " device" + (Local.BluetoothService.devices.length === 1 ? "" : "s") + " available"
              : "Bluetooth disabled"
        color: Core.Colors.muted
        font.family: Core.Colors.fontFamily
        font.pixelSize: 10
    }

    ListView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        spacing: Core.MenuStyle.sharedSpacing.small
        model: [...Local.BluetoothService.devices].sort((a, b) =>
            (b.connected - a.connected) || (b.paired - a.paired) || a.name.localeCompare(b.name))

        delegate: Rectangle {
            required property var modelData
            readonly property bool loading: modelData.state === BluetoothDeviceState.Connecting
                                            || modelData.state === BluetoothDeviceState.Disconnecting
            width: ListView.view.width
            height: 42
            radius: Core.MenuStyle.sharedRadius.card
            color: deviceMouse.pressed
                   ? Core.MenuStyle.pressedRule.accentSurface
                   : deviceMouse.containsMouse
                   ? Core.MenuStyle.hoverRule.surface
                   : modelData.connected
                   ? Core.MenuStyle.activeRule.surface
                   : Core.MenuStyle.inactiveRule.surface
            border.width: Core.MenuStyle.sharedRadius.border
            border.color: modelData.connected ? Core.Colors.accent : Core.Colors.muted
            Behavior on color {
                ColorAnimation {
                    duration: Core.MenuStyle.toggleRule.duration
                    easing.type: Core.MenuStyle.bezierSplineType
                    easing.bezierCurve: Core.MenuStyle.sharedAnimation.fastSpatialCurve
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Core.MenuStyle.sharedSpacing.medium
                anchors.rightMargin: Core.MenuStyle.sharedSpacing.medium
                spacing: Core.MenuStyle.sharedSpacing.small
                Text {
                    text: modelData.connected ? "●" : "○"
                    color: modelData.connected ? Core.Colors.accent : Core.Colors.muted
                    font.pixelSize: 12
                }
                Text {
                    Layout.fillWidth: true
                    text: modelData.name || modelData.address
                    color: Core.Colors.foreground
                    font.family: Core.Colors.fontFamily
                    font.pixelSize: 10
                    elide: Text.ElideRight
                }
                Text {
                    visible: loading
                    text: "..."
                    color: Core.Colors.muted
                    font.pixelSize: 10
                }
                Text {
                    visible: modelData.batteryAvailable
                    text: Math.round(modelData.battery * 100) + "%"
                    color: Core.Colors.muted
                    font.pixelSize: 9
                }
            }

            MouseArea {
                id: deviceMouse
                anchors.fill: parent
                hoverEnabled: true
                enabled: !loading && Local.BluetoothService.enabled
                onClicked: Local.BluetoothService.toggleDevice(modelData)
            }
        }

        Text {
            anchors.centerIn: parent
            visible: Local.BluetoothService.enabled && Local.BluetoothService.devices.length === 0
            text: Local.BluetoothService.discovering ? "SEARCHING..." : "NO DEVICES"
            color: Core.Colors.muted
            font.family: Core.Colors.fontFamily
            font.pixelSize: 10
        }
    }
}

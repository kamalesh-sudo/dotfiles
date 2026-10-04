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
            color: Core.Colors.textColor
            font.family: Core.Colors.fontFamily
            font.pixelSize: Core.MenuStyle.connectivity.headingFontSize
            font.weight: Core.Colors.titleWeight
        }
        Text {
            text: Local.BluetoothService.enabled ? "ON" : "OFF"
            color: Local.BluetoothService.enabled ? Core.Colors.iconColor : Core.Colors.mutedText
            font.family: Core.Colors.fontFamily
            font.pixelSize: Core.MenuStyle.connectivity.bodyFontSize
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: Core.MenuStyle.sharedSpacing.small

        Core.SharpShape {
            Layout.fillWidth: true
            cutBottomRight: false
            height: Core.MenuStyle.connectivity.passwordHeight
            fillColor: enabledMouse.pressed
                   ? Core.MenuStyle.pressedRule.accentSurface
                   : enabledMouse.containsMouse
                   ? Core.MenuStyle.toggleRule.hoverSurface
                   : Local.BluetoothService.enabled
                   ? Core.MenuStyle.toggleRule.onSurface
                   : Core.MenuStyle.toggleRule.offSurface
            strokeWidth: Core.MenuStyle.sharedRadius.border
            strokeColor: Core.Colors.borderColor
            Behavior on fillColor {
                ColorAnimation {
                    duration: Core.MenuStyle.toggleRule.duration
                    easing.type: Core.MenuStyle.bezierSplineType
                    easing.bezierCurve: Core.MenuStyle.sharedAnimation.fastSpatialCurve
                }
            }
            Text {
                anchors.centerIn: parent
                text: Local.BluetoothService.enabled ? "DISABLE" : "ENABLE"
                color: Core.Colors.textColor
                font.family: Core.Colors.fontFamily
                font.pixelSize: Core.MenuStyle.connectivity.metadataFontSize
            }
            MouseArea {
                id: enabledMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: Local.BluetoothService.toggleEnabled()
            }
        }

        Core.SharpShape {
            Layout.fillWidth: true
            cutBottomRight: false
            height: Core.MenuStyle.connectivity.passwordHeight
            fillColor: discoverMouse.pressed
                   ? Core.MenuStyle.pressedRule.accentSurface
                   : discoverMouse.containsMouse
                   ? Core.MenuStyle.dockButtonRule.activeSurface
                   : Core.MenuStyle.sharedSurface.input
            strokeWidth: Core.MenuStyle.sharedRadius.border
            strokeColor: Core.Colors.borderColor
            Behavior on fillColor {
                ColorAnimation {
                    duration: Core.MenuStyle.hoverRule.duration
                    easing.type: Core.MenuStyle.bezierSplineType
                    easing.bezierCurve: Core.MenuStyle.sharedAnimation.fastEffectsCurve
                }
            }
            Text {
                anchors.centerIn: parent
                text: Local.BluetoothService.discovering ? "STOP SCAN" : "SCAN"
                color: Core.Colors.textColor
                font.family: Core.Colors.fontFamily
                font.pixelSize: Core.MenuStyle.connectivity.metadataFontSize
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
        color: Core.Colors.mutedText
        font.family: Core.Colors.fontFamily
        font.pixelSize: Core.MenuStyle.connectivity.bodyFontSize
    }

    ListView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        spacing: Core.MenuStyle.sharedSpacing.small
        model: [...Local.BluetoothService.devices].sort((a, b) =>
            (b.connected - a.connected) || (b.paired - a.paired) || a.name.localeCompare(b.name))

        delegate: Core.SharpShape {
            required property var modelData
            cutBottomRight: false
            readonly property bool loading: modelData.state === BluetoothDeviceState.Connecting
                                            || modelData.state === BluetoothDeviceState.Disconnecting
            width: ListView.view.width
            height: Core.MenuStyle.connectivity.networkRowHeight
            fillColor: deviceMouse.pressed
                   ? Core.MenuStyle.pressedRule.accentSurface
                   : deviceMouse.containsMouse
                   ? Core.MenuStyle.dockButtonRule.activeSurface
                   : modelData.connected
                   ? Core.MenuStyle.dockButtonRule.activeSurface
                   : Core.MenuStyle.dockButtonRule.idleSurface
            strokeWidth: Core.MenuStyle.sharedRadius.border
            strokeColor: modelData.connected ? Core.Colors.borderColor : Core.Colors.mutedText
            Behavior on fillColor {
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
                    color: modelData.connected ? Core.Colors.iconColor : Core.Colors.mutedText
                    font.pixelSize: Core.MenuStyle.connectivity.headingFontSize
                }
                Text {
                    Layout.fillWidth: true
                    text: modelData.name || modelData.address
                    color: Core.Colors.textColor
                    font.family: Core.Colors.fontFamily
                    font.pixelSize: Core.MenuStyle.connectivity.bodyFontSize
                    elide: Text.ElideRight
                }
                Text {
                    visible: loading
                    text: "..."
                    color: Core.Colors.mutedText
                    font.pixelSize: Core.MenuStyle.connectivity.bodyFontSize
                }
                Text {
                    visible: modelData.batteryAvailable
                    text: Math.round(modelData.battery * 100) + "%"
                    color: Core.Colors.mutedText
                    font.pixelSize: Core.MenuStyle.connectivity.metadataFontSize
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
            color: Core.Colors.mutedText
            font.family: Core.Colors.fontFamily
            font.pixelSize: Core.MenuStyle.connectivity.bodyFontSize
        }
    }
}

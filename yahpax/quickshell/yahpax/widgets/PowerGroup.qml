import QtQuick
import Quickshell
import Quickshell.Wayland
import "../core" as Core

Item {
    id: window
    required property var modelData
    property Item inputItem: inputRegion

        readonly property int buttonWidth: Core.MenuStyle.bar.actionWidth
        readonly property int buttonHeight: Core.MenuStyle.bar.baseHeight - Core.MenuStyle.bar.actionHeightOffset
        readonly property int buttonSpacing: Core.MenuStyle.sharedSpacing.small
        readonly property int groupWidth: buttonWidth * 4 + buttonSpacing * 3
        readonly property real barWidth: Math.min(Core.MenuStyle.bar.collapsedWidthMax, modelData.width * Core.MenuStyle.bar.collapsedWidthRatio)

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: Core.MenuStyle.bar.actionHeightOffset
        // Anchor after the actual responsive bar width and its 18px cluster
        // inset, rather than against the screen's right edge.
        anchors.leftMargin: (modelData.width - barWidth) / 2 + barWidth + buttonSpacing
        width: groupWidth
        height: buttonHeight

        // Keep the input region stable while the visual group translates in
        // from the closed position. It exists only while the menu is open.
        Item {
            id: inputRegion
            anchors.fill: parent
            visible: Core.AppState.powerMenuVisible
        }

        Row {
            id: group
            anchors.fill: parent
            spacing: window.buttonSpacing
            opacity: Core.AppState.powerMenuVisible ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: Core.AppState.powerMenuVisible
                        ? Core.MenuStyle.menuTransition.openDuration
                        : Core.MenuStyle.menuTransition.closeDuration
                    easing.type: Core.MenuStyle.bezierSplineType
                    easing.bezierCurve: Core.MenuStyle.menuTransition.openEasing
                }
            }
            transform: Translate {
                x: Core.AppState.powerMenuVisible ? 0 : -window.groupWidth
                Behavior on x {
                    NumberAnimation {
                        duration: Core.AppState.powerMenuVisible
                            ? Core.MenuStyle.menuTransition.openDuration
                            : Core.MenuStyle.menuTransition.closeDuration
                        easing.type: Core.MenuStyle.bezierSplineType
                        easing.bezierCurve: Core.MenuStyle.menuTransition.openEasing
                    }
                }
            }

            Repeater {
                model: [
                    { glyph: "\uf011", action: "shutdown" },
                    { glyph: "\uf186", action: "sleep" },
                    { glyph: "\uf023", action: "lock" },
                    { glyph: "\udb81\udf09", action: "reboot" }
                ]

                delegate: Core.SharpShape {
                    required property var modelData
                    width: window.buttonWidth
                    height: window.buttonHeight
                    cutBottomLeft: true
                    cutBottomRight: true
                    cutAmount: Core.MenuStyle.radius
                    // Power actions use the same active surface as the bar's
                    // Power toggle; only the glyph differs.
                    fillColor: Core.MenuStyle.toggleRule.onSurface
                    strokeColor: Core.Colors.borderColor
                    strokeWidth: Core.MenuStyle.sharedRadius.border

                    Text {
                        anchors.centerIn: parent
                        text: modelData.glyph
                        color: Core.Colors.secondaryText
                        font.family: Core.Colors.iconFontFamily
                        font.pixelSize: 13
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: Core.AppState.powerMenuVisible
                        acceptedButtons: Qt.LeftButton
                        onClicked: {
                            Core.AppState.runPowerAction(modelData.action)
                        }
                    }
                }
            }
}
}

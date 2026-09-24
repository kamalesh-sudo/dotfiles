import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../core" as Core

Item {
        id: window
        required property var modelData
        readonly property bool historyOpen: Core.AppState.notificationsOpen
        // The automatic popup and the notification center have separate
        // visibility/layout states, even though they share this surface.
        readonly property bool popupVisible: !historyOpen && hasNotifications
        readonly property bool centerVisible: historyOpen
        // One reversible progress value drives both opening and closing.
        property real surfaceProgress: (centerVisible || popupVisible) ? 1 : 0
        readonly property int maxPopups: Core.MenuStyle.notification.maxVisible
        // The outer surface includes the shared padding; this keeps the
        // actual card width compact and stable at the screen edge.
        // Match the bar's collapsed footprint while remaining responsive.
        readonly property int panelWidth: Math.min(Core.MenuStyle.notification.panelWidth, modelData.width - Core.MenuStyle.notification.screenPadding * 2)
        readonly property int panelPadding: Core.MenuStyle.sharedSpacing.paddingLarge
        readonly property int maxPanelHeight: Math.min(Core.MenuStyle.notification.maxPanelHeight, Math.max(Core.MenuStyle.notification.minPanelHeight, modelData.height - Core.MenuStyle.notification.screenPadding * 2))
        readonly property var visibleNotifications: historyOpen
            ? Core.AppState.notifications.filter(item => !item.closed)
            : Core.AppState.popupItems()
        readonly property bool hasNotifications: visibleNotifications.length > 0
        // Remove the surface from the global input mask while fully closed.
        property Item inputItem: (centerVisible || popupVisible) ? surface : null
        property real clock: Date.now()

        Behavior on surfaceProgress {
            NumberAnimation {
                duration: Core.MenuStyle.menuTransition.popupDuration
                easing.type: Core.MenuStyle.bezierSplineType
                easing.bezierCurve: Core.MenuStyle.sharedAnimation.defaultSpatialCurve
            }
        }

        anchors.fill: parent
        readonly property int popupHeight: Math.min(maxPanelHeight,
            Math.max(1, list.contentHeight + panelPadding * 2
                + (historyOpen ? header.implicitHeight + Core.MenuStyle.sharedSpacing.small : 0)))
        visible: true

        Timer {
            interval: Core.MenuStyle.notification.clockRefreshInterval
            repeat: true
            running: true
            onTriggered: window.clock = Date.now()
        }

        IpcHandler {
            target: "notifications"
            function toggle(): void { Core.AppState.toggleNotifications() }
            function open(): void { Core.AppState.openNotifications() }
            function close(): void { Core.AppState.closeNotifications() }
            function clear(): void { Core.AppState.clearNotifications() }
        }

        IpcHandler {
            target: "notification"
            function toggle(): void { Core.AppState.toggleNotifications() }
            function open(): void { Core.AppState.openNotifications() }
            function close(): void { Core.AppState.closeNotifications() }
        }

        // Layer 1: the full-screen, screen-attached Yahpax surface.  The
        // compositor blur and input region belong to this layer only.
        MenuPanel {
            id: surface
            // Both automatic popups and Notification Center use the same
            // screen-attached top-right coordinate space.
            x: parent.width - width
            y: 0
            width: window.panelWidth
            height: window.popupHeight
            // Layer 2/3 are created by each delegate below. The same MenuPanel
            // used by Bar's expanded surface owns the visible shell here.
            surfaceColor: Core.MenuStyle.globalSurfaceColor
            outlineColor: Core.MenuStyle.globalBorderColor
            outlineWidth: Core.MenuStyle.sharedRadius.border
            surfaceOpacity: window.surfaceProgress
            transform: Translate { y: (1 - window.surfaceProgress) * Core.MenuStyle.popup.entryOffset }

            Behavior on height {
                NumberAnimation {
                    duration: Core.MenuStyle.menuTransition.popupDuration
                    easing.type: Core.MenuStyle.bezierSplineType
                    easing.bezierCurve: Core.MenuStyle.sharedAnimation.defaultSpatialCurve
                }
            }

            Behavior on x {
                NumberAnimation {
                    duration: Core.MenuStyle.menuTransition.popupDuration
                    easing.type: Core.MenuStyle.bezierSplineType
                    easing.bezierCurve: Core.MenuStyle.sharedAnimation.defaultSpatialCurve
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: window.panelPadding
                spacing: Core.MenuStyle.sharedSpacing.small

                RowLayout {
                    id: header
                    visible: window.historyOpen
                    Layout.fillWidth: true

                    Text {
                        Layout.fillWidth: true
                        text: "Notifications"
                        color: Core.Colors.secondaryText
                        font.family: Core.Colors.fontFamily
                        font.pixelSize: Core.MenuStyle.notification.headerFontSize
                        font.weight: Core.Colors.titleWeight
                    }

                    Rectangle {
                        implicitWidth: Core.MenuStyle.notification.clearButtonSize
                        implicitHeight: Core.MenuStyle.notification.clearButtonSize
                        radius: height / 2
                        border.width: Core.MenuStyle.sharedRadius.border
                        border.color: Core.Colors.accent
                        color: clearMouse.pressed
                               ? Core.MenuStyle.dockButtonRule.pressedSurface
                               : clearMouse.containsMouse
                               ? Core.MenuStyle.dockButtonRule.activeSurface
                               : Core.MenuStyle.dockButtonRule.idleSurface

                        Text {
                            anchors.centerIn: parent
                            text: "\uf00d"
                            color: Core.Colors.icon
                            font.family: Core.Colors.iconFontFamily
                            font.pixelSize: Core.MenuStyle.notification.clearFontSize
                        }

                        MouseArea {
                            id: clearMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: Core.AppState.clearNotifications()
                        }
                    }
                }

                ListView {
                    id: list
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: !window.historyOpen || window.hasNotifications
                    clip: true
                    spacing: Core.MenuStyle.sharedSpacing.medium
                    model: window.visibleNotifications
                    boundsBehavior: Flickable.StopAtBounds
                    cacheBuffer: window.modelData.height

                    add: Transition {
                        NumberAnimation {
                            properties: "x,opacity"
                            from: list.width
                            to: 0
                            duration: Core.MenuStyle.menuTransition.openDuration
                            easing.type: Core.MenuStyle.bezierSplineType
                            easing.bezierCurve: Core.MenuStyle.sharedAnimation.defaultSpatialCurve
                        }
                    }
                    move: Transition {
                        NumberAnimation {
                            properties: "y"
                            duration: Core.MenuStyle.menuTransition.openDuration
                            easing.type: Core.MenuStyle.bezierSplineType
                            easing.bezierCurve: Core.MenuStyle.sharedAnimation.defaultSpatialCurve
                        }
                    }
                    displaced: Transition {
                        NumberAnimation {
                            properties: "y"
                            duration: Core.MenuStyle.menuTransition.openDuration
                            easing.type: Core.MenuStyle.bezierSplineType
                            easing.bezierCurve: Core.MenuStyle.sharedAnimation.defaultSpatialCurve
                        }
                    }

                    delegate: Item {
                        id: wrapper
                        required property var modelData
                        width: list.width
                        readonly property bool popupMode: !window.historyOpen
                        readonly property var actions: wrapper.modelData.actions || []
                        implicitHeight: card.implicitHeight

                        ListView.onRemove: removeAnimation.start()

                        SequentialAnimation {
                            id: removeAnimation
                            PropertyAction { target: wrapper; property: "ListView.delayRemove"; value: true }
                            NumberAnimation {
                                target: card
                                property: "x"
                                to: card.x >= 0
                                    ? wrapper.width * Core.MenuStyle.popup.removalDistance
                                    : -wrapper.width * Core.MenuStyle.popup.removalDistance
                                duration: Core.MenuStyle.normalDuration
                                easing.type: Core.MenuStyle.bezierSplineType
                                easing.bezierCurve: Core.MenuStyle.sharedAnimation.defaultSpatialCurve
                            }
                            PropertyAction { target: wrapper; property: "ListView.delayRemove"; value: false }
                        }

                        // Layer 2: one compact notification card.
                        Core.SharpShape {
                            id: card
                            width: parent.width
                            implicitHeight: content.implicitHeight + Core.MenuStyle.sharedSpacing.paddingMedium * 2
                            cutBottomLeft: true
                            cutBottomRight: true
                            cutAmount: Core.MenuStyle.radius
                            fillColor: wrapper.modelData.urgency === 2
                                ? Core.Colors.accentSoftSurface
                                : Core.MenuStyle.globalSurfaceColor
                            strokeWidth: Core.MenuStyle.sharedRadius.border
                            strokeColor: wrapper.modelData.urgency === 2 ? Core.Colors.accent : Core.MenuStyle.globalBorderColor
                            // Popup cards stay compact; only center cards use
                            // the center's expanded content presentation.
                            property bool expanded: !wrapper.popupMode

                            Component.onCompleted: x = 0

                            Behavior on x {
                                NumberAnimation {
                                    duration: Core.MenuStyle.menuTransition.openDuration
                                    easing.type: Core.MenuStyle.bezierSplineType
                                    easing.bezierCurve: Core.MenuStyle.sharedAnimation.defaultSpatialCurve
                                }
                            }
                            Behavior on implicitHeight {
                                NumberAnimation {
                                    duration: Core.MenuStyle.menuTransition.expandDuration
                                    easing.type: Core.MenuStyle.bezierSplineType
                                    easing.bezierCurve: Core.MenuStyle.sharedAnimation.defaultSpatialCurve
                                }
                            }

                            Timer {
                                id: expiry
                                // Keep the expiry anchored to this item's
                                // arrival, even if it waited in the FIFO
                                // queue before receiving a visible slot.
                                interval: Math.max(1,
                                    Core.MenuStyle.notification.popupDuration
                                    - Math.max(0, Date.now() - Number(wrapper.modelData.createdAt || Date.now())))
                                running: wrapper.popupMode && wrapper.modelData.popup
                                onTriggered: Core.AppState.expireNotification(wrapper.modelData.id)
                            }

                            ColumnLayout {
                                id: content
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: Core.MenuStyle.sharedSpacing.paddingMedium
                                spacing: Core.MenuStyle.sharedSpacing.small

                                RowLayout {
                                    id: headerRow
                                    Layout.fillWidth: true
                                    spacing: Core.MenuStyle.sharedSpacing.medium

                                    Item {
                                        implicitWidth: Core.MenuStyle.notification.iconSize
                                        implicitHeight: Core.MenuStyle.notification.iconSize

                                        Rectangle {
                                            anchors.fill: parent
                                            radius: height / 2
                                            color: wrapper.modelData.urgency === 2 ? Core.Colors.accent : Core.MenuStyle.globalSurfaceColor
                                        }

                                        Image {
                                            id: notificationImage
                                            anchors.fill: parent
                                            anchors.margins: Core.MenuStyle.notification.iconInset
                                            source: wrapper.modelData.image || (wrapper.modelData.appIcon ? Quickshell.iconPath(wrapper.modelData.appIcon) : "")
                                            fillMode: Image.PreserveAspectCrop
                                            asynchronous: true
                                            visible: status === Image.Ready
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: "\uf0f3"
                                            color: Core.Colors.icon
                                            font.family: Core.Colors.iconFontFamily
                                            font.pixelSize: Core.MenuStyle.notification.fallbackIconFontSize
                                            visible: !notificationImage.visible
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: Core.MenuStyle.notification.compactRowSpacing

                                        Text {
                                            Layout.fillWidth: true
                                            text: wrapper.modelData.appName || "Notification"
                                            color: Core.Colors.onSurfaceVariant
                                            font.family: Core.Colors.fontFamily
                                            font.pixelSize: Core.MenuStyle.notification.metadataFontSize
                                            elide: Text.ElideRight
                                            visible: !wrapper.popupMode
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: wrapper.popupMode
                                                ? wrapper.modelData.summary + "  ·  " + window.timeLabel(wrapper.modelData.createdAt)
                                                : wrapper.modelData.summary
                                            color: Core.Colors.onSurface
                                            font.family: Core.Colors.fontFamily
                                            font.pixelSize: Core.MenuStyle.notification.summaryFontSize
                                            font.weight: Core.Colors.labelWeight
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: window.timeLabel(wrapper.modelData.createdAt)
                                            color: Core.Colors.onSurfaceVariant
                                            font.family: Core.Colors.fontFamily
                                            font.pixelSize: Core.MenuStyle.notification.metadataFontSize
                                            visible: !wrapper.popupMode
                                        }
                                    }

                                    Core.SharpShape {
                                        id: dismissButton
                                        Layout.alignment: Qt.AlignVCenter
                                        Layout.preferredWidth: Core.MenuStyle.notification.dismissSize
                                        Layout.preferredHeight: Core.MenuStyle.notification.dismissSize
                                        width: Core.MenuStyle.notification.dismissSize
                                        height: Core.MenuStyle.notification.dismissSize
                                        cutBottomLeft: true
                                        cutBottomRight: true
                                        cutAmount: Core.MenuStyle.radius
                                        strokeColor: Core.Colors.accent
                                        strokeWidth: Core.MenuStyle.sharedRadius.border
                                        fillColor: dismissMouse.pressed
                                                  ? Core.MenuStyle.dockButtonRule.pressedSurface
                                                  : dismissMouse.containsMouse
                                                  ? Core.MenuStyle.dockButtonRule.activeSurface
                                                  : Core.MenuStyle.dockButtonRule.idleSurface

                                        Text {
                                            anchors.centerIn: parent
                                            text: "\uf00d"
                                            color: Core.Colors.icon
                                            font.family: Core.Colors.iconFontFamily
                                            font.pixelSize: Core.MenuStyle.notification.dismissFontSize
                                        }

                                        MouseArea {
                                            id: dismissMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            acceptedButtons: Qt.LeftButton
                                            onClicked: {
                                                expiry.stop()
                                                Core.AppState.dismissNotification(wrapper.modelData.id)
                                            }
                                        }
                                    }
                                }

                                // Layer 3: expanded notification content.
                                Text {
                                    id: body
                                    Layout.fillWidth: true
                                    textFormat: /[<*_`#\[\]]/.test(wrapper.modelData.body || "") ? Text.MarkdownText : Text.PlainText
                                    text: wrapper.modelData.body
                                    color: Core.Colors.onSurface
                                    font.family: Core.Colors.fontFamily
                                    font.pixelSize: Core.MenuStyle.notification.bodyFontSize
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    maximumLineCount: Core.MenuStyle.notification.bodyMaxLines
                                    elide: Text.ElideRight
                                    visible: card.expanded && text.length > 0
                                }

                                Text {
                                    id: bodyPreview
                                    Layout.fillWidth: true
                                    textFormat: /[<*_`#\[\]]/.test(wrapper.modelData.body || "") ? Text.MarkdownText : Text.PlainText
                                    text: wrapper.modelData.body
                                    color: Core.Colors.onSurfaceVariant
                                    font.family: Core.Colors.fontFamily
                                    font.pixelSize: Core.MenuStyle.notification.bodyFontSize
                                    maximumLineCount: Core.MenuStyle.notification.previewMaxLines
                                    elide: Text.ElideRight
                                    visible: !card.expanded && text.length > 0
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: Core.MenuStyle.sharedSpacing.tiny
                                    visible: card.expanded && wrapper.actions.length > 0

                                    Repeater {
                                        model: wrapper.actions
                                        delegate: Rectangle {
                                            required property var modelData
                                            Layout.fillWidth: true
                                            implicitHeight: Core.MenuStyle.notification.actionHeight
                                            radius: Core.MenuStyle.sharedRadius.card
                                            color: actionMouse.containsMouse ? Core.MenuStyle.hoverRule.surface : Core.MenuStyle.globalSurfaceColor

                                            Text {
                                                anchors.centerIn: parent
                                                text: modelData.text
                                                color: Core.Colors.onSurface
                                                font.family: Core.Colors.fontFamily
                                                font.pixelSize: Core.MenuStyle.notification.actionFontSize
                                                elide: Text.ElideRight
                                            }

                                            MouseArea {
                                                id: actionMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                onClicked: modelData.invoke()
                                            }
                                        }
                                    }

                                }
                            }

                            MouseArea {
                                id: gestureArea
                                anchors.fill: parent
                                z: -1
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                                preventStealing: true
                                property real startX
                                property real startY

                                onEntered: expiry.stop()
                                onExited: if (!pressed) expiry.start()
                                onPressed: event => {
                                    expiry.stop()
                                    startX = event.x
                                    startY = event.y
                                    if (event.button === Qt.MiddleButton)
                                        Core.AppState.dismissNotification(wrapper.modelData.id)
                                }
                                onReleased: {
                                    if (!containsMouse)
                                        expiry.start()
                                    if (Math.abs(card.x) >= card.width * Core.MenuStyle.popup.swipeThreshold)
                                        Core.AppState.hideNotificationPopup(wrapper.modelData.id)
                                    else
                                        card.x = 0
                                }
                                onPositionChanged: event => {
                                    if (pressed && event.buttons & Qt.LeftButton) {
                                        const verticalDelta = event.y - startY
                                        if (wrapper.popupMode && Math.abs(verticalDelta) > Core.MenuStyle.popup.expandThreshold)
                                            card.expanded = verticalDelta > 0
                                        card.x = Math.max(-card.width, Math.min(card.width, event.x - startX))
                                    }
                                }
                                onClicked: event => {
                                    if (event.button === Qt.LeftButton && wrapper.modelData.actions.length === 1)
                                        wrapper.modelData.actions[0].invoke()
                                }
                            }
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: window.historyOpen && !window.hasNotifications
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text: "Nothing here, shut up and do your work."
                    color: Core.Colors.secondaryText
                    font.family: Core.Colors.fontFamily
                    font.pixelSize: Core.MenuStyle.notification.bodyFontSize
                }
            }
        }

        function timeLabel(createdAt): string {
            const minutes = Math.floor((clock - Number(createdAt || clock)) / 60000)
            if (minutes < 1)
                return "now"
            if (minutes < 60)
                return minutes + "m"
            const hours = Math.floor(minutes / 60)
            if (hours < 24)
                return hours + "h"
            return Math.floor(hours / 24) + "d"
        }
}

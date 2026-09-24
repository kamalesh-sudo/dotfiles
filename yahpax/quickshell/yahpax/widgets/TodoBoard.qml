import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import "../core" as Core

Item {
    id: root
    required property var modelData
    property Item inputItem: win

    // These dimensions and visual bindings mirror Dock.qml exactly.
    readonly property int noteWidth: Core.MenuStyle.layout.todo.cardWidth
    readonly property int noteHeight: Core.MenuStyle.layout.todo.cardHeight
    readonly property int gap: Core.MenuStyle.layout.todo.gap
    readonly property int margin: Core.MenuStyle.layout.todo.margin
    readonly property var visibleTodos: Core.AppState.todos
        .filter(item => !item.checked)
        .slice()
        .sort((a, b) => Number(a.id) - Number(b.id))
        .slice(0, Core.MenuStyle.layout.todo.maxVisible)
    property var locallyNotified: ({})

    function todoKey(item) {
        return String(item.id) + "\u001f" + String(item.text) + "\u001f" + String(item.reminderTime)
    }

    function syncNotificationMemory() {
        const next = {}
        for (const item of Core.AppState.todos.filter(item => !item.checked)) {
            const key = root.todoKey(item)
            if (root.locallyNotified[key]) next[key] = root.locallyNotified[key]
        }
        root.locallyNotified = next
    }

    function checkReminders() {
        const now = new Date()
        for (const item of Core.AppState.todos.filter(item => !item.checked)) {
            if (!item.reminderTime) continue
            const parts = String(item.reminderTime).split(":")
            if (parts.length !== 2) continue
            const scheduled = new Date(now.getFullYear(), now.getMonth(), now.getDate(), Number(parts[0]), Number(parts[1]), 0, 0)
            if (now < scheduled) continue

            const last = item.lastNotifiedAt ? new Date(item.lastNotifiedAt) : null
            const localLast = root.locallyNotified[root.todoKey(item)] || 0
            const lastMillis = Math.max(last && !isNaN(last.getTime()) ? last.getTime() : 0, localLast)
            if (lastMillis && now.getTime() - lastMillis < 3600000) continue

            root.locallyNotified[root.todoKey(item)] = now.getTime()
            Core.AppState.addNotification("Todo reminder", item.text, "normal")
            Core.AppState.markTodoNotified(item.id)
        }
    }

    Item {
        id: win
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: Core.MenuStyle.layout.todo.topOffset
        anchors.rightMargin: Core.MenuStyle.layout.todo.rightOffset
        width: root.margin * 2 + root.noteWidth * 2 + root.gap
        height: root.margin * 2 + root.noteHeight * 3 + root.gap * 2
        visible: Core.AppState.showDesktopWidgets && root.visibleTodos.length > 0

            Repeater {
                model: root.visibleTodos

                delegate: Item {
                    id: entry
                    required property var modelData
                    readonly property int slotId: Number(modelData.id)
                    readonly property int row: Math.floor((slotId - 1) / 2)
                    readonly property int column: (slotId - 1) % 2
                    property bool hovered: mouse.containsMouse
                    width: root.noteWidth
                    height: root.noteHeight
                    x: root.margin + column * (root.noteWidth + root.gap)
                    y: root.margin + row * (root.noteHeight + root.gap)

                    Core.SharpShape {
                        id: body
                        anchors.fill: parent
                        cutBottomLeft: true
                        cutBottomRight: true
                        cutAmount: Core.MenuStyle.radius
                        fillColor: entry.hovered ? Core.Colors.widgetHover : Core.Colors.widgetBackground
                        strokeWidth: 1
                        strokeColor: entry.hovered
                            ? Core.Colors.accent
                            : Core.Colors.separator
                        transform: Matrix4x4 {
                            matrix: Qt.matrix4x4(1, 0.28, 0, -8,  0, 1, 0, 0,  0, 0, 1, 0,  0, 0, 0, 1)
                        }
                        Behavior on fillColor { ColorAnimation { duration: Core.MenuStyle.sharedAnimation.duration; easing.type: Core.MenuStyle.bezierSplineType; easing.bezierCurve: Core.MenuStyle.sharedAnimation.defaultEffectsCurve } }
                        Behavior on strokeColor { ColorAnimation { duration: Core.MenuStyle.sharedAnimation.duration; easing.type: Core.MenuStyle.bezierSplineType; easing.bezierCurve: Core.MenuStyle.sharedAnimation.defaultEffectsCurve } }

                        Rectangle {
                            anchors { top: parent.top; left: parent.left; right: parent.right }
                            height: 1
                            color: Core.Colors.separatorOverlay
                        }
                        Rectangle {
                            anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                            height: 2
                            color: Core.Colors.accent
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { to: 1.0; duration: 1100; easing.type: Easing.InOutSine }
                                NumberAnimation { to: 0.35; duration: 1100; easing.type: Easing.InOutSine }
                            }
                        }
                    }

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: Core.MenuStyle.layout.todo.contentLeftPadding
                        anchors.right: check.left
                        anchors.rightMargin: Core.MenuStyle.layout.todo.contentRightPadding
                        spacing: Core.MenuStyle.layout.todo.rowSpacing

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                text: modelData.text
                                color: entry.hovered ? Core.Colors.accent : Core.Colors.foreground
                                font.pixelSize: Core.MenuStyle.layout.todo.titleFontSize
                                font.bold: entry.hovered
                                font.family: Core.Colors.fontFamily
                                elide: Text.ElideRight
                                width: Core.MenuStyle.layout.todo.titleWidth
                                Behavior on color { ColorAnimation { duration: Core.MenuStyle.sharedAnimation.duration; easing.type: Core.MenuStyle.bezierSplineType; easing.bezierCurve: Core.MenuStyle.sharedAnimation.defaultEffectsCurve } }
                            }
                            Text {
                                text: "slot " + modelData.id
                                color: Core.Colors.muted
                                font.pixelSize: Core.MenuStyle.layout.todo.metadataFontSize
                                font.family: Core.Colors.fontFamily
                            }
                        }
                    }

                    Rectangle {
                        id: check
                        z: 1
                        width: Core.MenuStyle.layout.todo.completeButtonSize
                        height: Core.MenuStyle.layout.todo.completeButtonSize
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                            color: entry.hovered ? Core.Colors.accentSoftSurface : Core.Colors.accentFaintSurface
                        border.width: 1
                        border.color: Core.Colors.accent
                        Behavior on color { ColorAnimation { duration: Core.MenuStyle.sharedAnimation.duration; easing.type: Core.MenuStyle.bezierSplineType; easing.bezierCurve: Core.MenuStyle.sharedAnimation.defaultEffectsCurve } }

                        Text {
                            anchors.centerIn: parent
                            text: "✓"
                            color: Core.Colors.accent
                            font.pixelSize: Core.MenuStyle.layout.todo.completeFontSize
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: Core.AppState.checkTodo(modelData.id)
                        }
                    }

                    MouseArea {
                        id: mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        z: 0
                    }
                }
            }
    }

    Timer {
        interval: Core.MenuStyle.layout.todo.reminderInterval
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.checkReminders()
    }

    Connections {
        target: Core.AppState
        function onTodosChanged() {
            root.syncNotificationMemory()
            root.checkReminders()
        }
    }

    IpcHandler {
        target: "todoBoard"
        function refresh(): void { Core.AppState.loadTodos() }
        function toggle(): void { Core.AppState.loadTodos() }
    }
}

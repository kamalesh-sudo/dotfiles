import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import "../core" as Core

Item {
    id: root

    // These dimensions and visual bindings mirror Dock.qml exactly.
    readonly property int noteWidth: 300
    readonly property int noteHeight: 60
    readonly property int gap: 16
    readonly property int margin: 20
    readonly property var visibleTodos: Core.AppState.todos
        .filter(item => !item.checked)
        .slice()
        .sort((a, b) => Number(a.id) - Number(b.id))
        .slice(0, 6)
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

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property var modelData
            screen: modelData

            anchors.top: true
            anchors.right: true
            margins.top: 92
            margins.right: 28
            implicitWidth: root.margin * 2 + root.noteWidth * 2 + root.gap
            implicitHeight: root.margin * 2 + root.noteHeight * 3 + root.gap * 2
            color: "transparent"
            visible: Core.AppState.showDesktopWidgets && root.visibleTodos.length > 0

            WlrLayershell.layer: WlrLayer.Bottom
            // Reuse Dock.qml's existing blur rule rather than adding a new one.
            WlrLayershell.namespace: "quickshell-dock"
            exclusionMode: ExclusionMode.Ignore

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

                    Rectangle {
                        id: body
                        anchors.fill: parent
                        color: Qt.rgba(Core.Colors.background.r, Core.Colors.background.g,
                                       Core.Colors.background.b, entry.hovered ? 0.72 : 0.42)
                        border.width: 1
                        border.color: entry.hovered
                            ? Core.Colors.accent
                            : Qt.rgba(Core.Colors.accent2.r, Core.Colors.accent2.g, Core.Colors.accent2.b, 0.6)
                        transform: Matrix4x4 {
                            matrix: Qt.matrix4x4(1, 0.28, 0, -8,  0, 1, 0, 0,  0, 0, 1, 0,  0, 0, 0, 1)
                        }
                        Behavior on color { ColorAnimation { duration: 160 } }
                        Behavior on border.color { ColorAnimation { duration: 160 } }

                        Rectangle {
                            anchors { top: parent.top; left: parent.left; right: parent.right }
                            height: 1
                            color: "#55ffffff"
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
                        anchors.leftMargin: 24
                        anchors.right: check.left
                        anchors.rightMargin: 14
                        spacing: 13

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                text: modelData.text
                                color: entry.hovered ? Core.Colors.accent : Core.Colors.foreground
                                font.pixelSize: 15
                                font.bold: entry.hovered
                                font.family: Core.Colors.fontFamily
                                elide: Text.ElideRight
                                width: 220
                                Behavior on color { ColorAnimation { duration: 160 } }
                            }
                            Text {
                                text: "slot " + modelData.id
                                color: Core.Colors.muted
                                font.pixelSize: 10
                                font.family: Core.Colors.fontFamily
                            }
                        }
                    }

                    Rectangle {
                        id: check
                        z: 1
                        width: 22
                        height: 22
                        anchors.right: parent.right
                        anchors.rightMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        color: Qt.rgba(Core.Colors.accent.r, Core.Colors.accent.g,
                                       Core.Colors.accent.b, entry.hovered ? 0.28 : 0.14)
                        border.width: 1
                        border.color: Core.Colors.accent
                        Behavior on color { ColorAnimation { duration: 160 } }

                        Text {
                            anchors.centerIn: parent
                            text: "✓"
                            color: Core.Colors.accent
                            font.pixelSize: 16
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
    }

    Timer {
        interval: 60000
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

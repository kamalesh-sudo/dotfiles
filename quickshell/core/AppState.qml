pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root
    property bool showBar: true
    property bool showDesktopWidgets: true
    // Compatibility name for callers that still use the old panel property.
    // The morph mode is the single shared surface state.
    property alias activePanel: root.barMorph
    property var notifications: []
    property var todos: []
    property int notificationSerial: 0
    property bool notificationDrawerVisible: false
    property var popupNotification: null
    property Timer notificationPopupTimer: Timer {
        interval: 6000
        repeat: false
        onTriggered: root.popupNotification = null
    }

    property string barMorph: ""
    property real morphOriginX: 0
    property real morphOriginY: 0
    property real morphOriginWidth: 0
    property real morphOriginHeight: 0
    property real morphScreenHeight: 1080
    property string morphScreenName: ""
    property bool barTemporarilyHidden: false
    property Timer barHideTimer: Timer {
        interval: 1600
        repeat: false
        onTriggered: root.barTemporarilyHidden = false
    }

    signal morphRequested(string name)
    signal morphClosed(string screenName)

    property Process todoReader: Process {
        command: ["python3", Quickshell.shellDir + "/scripts/todo-store.py", "read"]
        stdout: StdioCollector {
            onStreamFinished: root.applyTodos(this.text)
        }
    }
    property Process todoMutation: Process {
        command: ["true"]
        stdout: StdioCollector {
            onStreamFinished: root.loadTodos()
        }
    }

    Component.onCompleted: root.loadTodos()

    function loadTodos() {
        todoReader.running = false
        todoReader.running = true
    }

    function applyTodos(raw) {
        try {
            const parsed = JSON.parse(raw || "[]")
            todos = Array.isArray(parsed) ? parsed : []
        } catch (error) {
            console.warn("TodoBoard: failed to parse todo store", error)
            todos = []
        }
    }

    function checkTodo(id) {
        todoMutation.command = ["python3", Quickshell.shellDir + "/scripts/todo-store.py", "check", "--id", String(id)]
        todoMutation.running = true
    }

    function markTodoNotified(id) {
        todoMutation.command = ["python3", Quickshell.shellDir + "/scripts/todo-store.py", "notify", "--id", String(id)]
        todoMutation.running = true
    }

    function openMorph(name, originX, originY, originWidth, originHeight, screenName, screenHeight) {
        morphOriginX = originX
        morphOriginY = originY
        morphOriginWidth = originWidth
        morphOriginHeight = originHeight
        morphScreenName = screenName
        morphScreenHeight = screenHeight
        barMorph = name
    }
    function closeMorph() { barMorph = "" }
    function requestMorph(name) { morphRequested(name) }
    function runPowerAction(action) {
        let command = ["true"]
        if (action === "lock") command = ["hyprlock"]
        else if (action === "sleep") command = ["systemctl", "suspend"]
        else if (action === "reboot") command = ["systemctl", "reboot"]
        else if (action === "shutdown") command = ["systemctl", "poweroff"]
        closeMorph()
        Quickshell.execDetached(command)
    }
    function hideBarTemporarily(ms) {
        barHideTimer.interval = ms
        barTemporarilyHidden = true
        barHideTimer.restart()
    }

    function openPanel(name) { activePanel = name }
    function closePanel() { activePanel = "" }
    function showNotificationPopup(item) {
        popupNotification = item
        notificationPopupTimer.restart()
    }

    function addNotification(summary, body, urgency) {
        const item = { id: ++notificationSerial, nativeId: 0, native: null,
                       appName: "Quickshell", appIcon: "", summary: String(summary || "Notification"),
                       body: String(body || ""), urgency: String(urgency || "normal"), actions: [] }
        notifications = [item].concat(notifications).slice(0, 50)
        showNotificationPopup(item)
    }

    function addSystemNotification(notification) {
        const item = { id: ++notificationSerial, nativeId: notification.id, native: notification,
                       appName: String(notification.appName || "Notification"),
                       appIcon: String(notification.appIcon || notification.image || ""),
                       summary: String(notification.summary || "Notification"),
                       body: String(notification.body || ""),
                       urgency: notification.urgency,
                       actions: notification.actions || [] }
        notifications = [item].concat(notifications.filter(existing => existing.nativeId !== item.nativeId)).slice(0, 50)
        showNotificationPopup(item)
    }

    function removeNotification(id) {
        notifications = notifications.filter(item => item.id !== id)
        if (popupNotification && popupNotification.id === id)
            popupNotification = null
    }

    function dismissNotification(id) {
        const item = notifications.find(candidate => candidate.id === id)
        if (item && item.native) item.native.dismiss()
        removeNotification(id)
    }

    function dismissNativeNotification(nativeId) {
        const item = notifications.find(candidate => candidate.nativeId === nativeId)
        if (item) removeNotification(item.id)
    }

    function syncNativeNotifications(active) {
        const ids = active.map(notification => notification.id)
        const retained = notifications.filter(item => !item.native || ids.includes(item.nativeId))
        if (retained.length !== notifications.length) notifications = retained
        if (popupNotification && popupNotification.native
                && !ids.includes(popupNotification.nativeId)) popupNotification = null
    }

    function invokeNotificationAction(id, action) {
        const item = notifications.find(candidate => candidate.id === id)
        if (!item || !item.native) return
        const selected = item.actions.find(candidate => candidate.identifier === action)
        if (selected) selected.invoke()
    }

    function clearNotifications() {
        notifications.slice().forEach(item => {
            if (!item.native) return
            try { item.native.dismiss() } catch (error) { }
        })
        notifications = []
        popupNotification = null
        notificationDrawerVisible = false
    }
}

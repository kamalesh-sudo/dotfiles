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
    property bool notificationsOpen: false

    property string barMorph: ""
    property bool powerMenuVisible: false
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
    function togglePowerMenu() { powerMenuVisible = !powerMenuVisible }
    function openPowerMenu() { powerMenuVisible = true }
    function closePowerMenu() { powerMenuVisible = false }
    function requestMorph(name) { morphRequested(name) }
    function runPowerAction(action) {
        let command = ["true"]
        if (action === "lock") command = ["hyprlock"]
        else if (action === "sleep") command = ["systemctl", "suspend"]
        else if (action === "reboot") command = ["systemctl", "reboot"]
        else if (action === "shutdown") command = ["systemctl", "poweroff"]
        closePowerMenu()
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
    function toggleNotifications() { notificationsOpen = !notificationsOpen }
    function openNotifications() { notificationsOpen = true }
    function closeNotifications() { notificationsOpen = false }

    function dismissNotification(id) {
        const item = notifications.find(notification => notification.id === id)
        if (item?.native && typeof item.native.dismiss === "function")
            item.native.dismiss()
        notifications = notifications.filter(notification => notification.id !== id)
    }

    function hideNotificationPopup(id) {
        const next = notifications.map(item => item.id === id
            ? Object.assign({}, item, { popup: false })
            : item)
        notifications = next
    }

    function expireNotification(id) {
        const item = notifications.find(notification => notification.id === id)
        if (!item)
            return
        hideNotificationPopup(id)
    }

    function clearNotifications() {
        const current = notifications
        notifications = []
        notificationsOpen = false
        for (const item of current) {
            if (item.native && typeof item.native.dismiss === "function")
                item.native.dismiss()
        }
    }

    function expireNotificationPopups() {
        const now = Date.now()
        let changed = false
        const next = notifications.map(item => {
            if (!item.popup || item.urgency === 2 || item.resident)
                return item

            const timeout = Number(item.expireTimeout)
            const lifetime = timeout > 0 ? timeout : 5000
            if (now - Number(item.createdAt || now) < lifetime)
                return item

            changed = true
            return Object.assign({}, item, { popup: false })
        })
        if (changed)
            notifications = next
    }

    function addNotification(summary, body, urgency) {
        const item = { id: ++notificationSerial, nativeId: 0, native: null,
                       appName: "Quickshell", appIcon: "", summary: String(summary || "Notification"),
                       body: String(body || ""), urgency: urgency === "critical" ? 2 : 1,
                       actions: [], popup: true, closed: false, resident: false,
                       expireTimeout: 5000, image: "", hints: {}, createdAt: Date.now() }
        notifications = [item].concat(notifications).slice(0, 50)
    }

    function addSystemNotification(notification) {
        const item = { id: ++notificationSerial, nativeId: notification.id, native: notification,
                       appName: String(notification.appName || "Notification"),
                       appIcon: String(notification.appIcon || notification.image || ""),
                       image: String(notification.image || ""),
                       summary: String(notification.summary || "Notification"),
                       body: String(notification.body || ""),
                       urgency: notification.urgency,
                       actions: (notification.actions || []).map(action => ({
                           text: String(action.text || "Action"),
                           invoke: function() { action.invoke() }
                       })),
                       popup: true, closed: false,
                       resident: Boolean(notification.resident),
                       expireTimeout: Number(notification.expireTimeout),
                       hints: notification.hints || {},
                       createdAt: Date.now() }
        notifications = [item].concat(notifications.filter(existing => existing.nativeId !== item.nativeId)).slice(0, 50)
    }

    function syncNativeNotifications(active) {
        const ids = active.map(notification => notification.id)
        const retained = notifications.filter(item => !item.native || ids.includes(item.nativeId))
        if (retained.length !== notifications.length) notifications = retained
    }
}

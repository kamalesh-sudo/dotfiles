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
    // Notification storage is separate from the popup lifecycle. These two
    // FIFO lists contain only internal notification ids.
    property var visiblePopups: []
    property var pendingPopupQueue: []
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

    function popupItems() {
        return visiblePopups
            .map(id => notifications.find(item => item.id === id))
            .filter(item => item !== undefined && !item.closed)
            .slice(0, 3)
    }

    function promotePopupQueue() {
        if (visiblePopups.length > 3) {
            const overflow = visiblePopups.slice(3)
            visiblePopups = visiblePopups.slice(0, 3)
            pendingPopupQueue = overflow.concat(pendingPopupQueue.filter(id => overflow.indexOf(id) < 0))
        }
        while (visiblePopups.length < 3 && pendingPopupQueue.length > 0) {
            const nextId = pendingPopupQueue[0]
            pendingPopupQueue = pendingPopupQueue.slice(1)
            const next = notifications.find(item => item.id === nextId)
            if (!next || !next.popup || next.closed)
                continue
            if (visiblePopups.indexOf(nextId) < 0)
                visiblePopups = visiblePopups.concat([nextId])
        }
    }

    function enqueuePopup(id) {
        if (visiblePopups.indexOf(id) >= 0 || pendingPopupQueue.indexOf(id) >= 0)
            return
        promotePopupQueue()
        if (visiblePopups.length < 3)
            visiblePopups = visiblePopups.concat([id])
        else
            pendingPopupQueue = pendingPopupQueue.concat([id])
    }

    function removePopup(id) {
        const wasVisible = visiblePopups.indexOf(id) >= 0
        visiblePopups = visiblePopups.filter(itemId => itemId !== id)
        pendingPopupQueue = pendingPopupQueue.filter(itemId => itemId !== id)

        const item = notifications.find(notification => notification.id === id)
        if (item) {
            notifications = notifications.map(notification => notification.id === id
                ? Object.assign({}, notification, { popup: false })
                : notification)
        }

        if (wasVisible)
            promotePopupQueue()
    }

    function dismissNotification(id) {
        const item = notifications.find(notification => notification.id === id)
        if (item?.native && typeof item.native.dismiss === "function")
            item.native.dismiss()
        removePopup(id)
        notifications = notifications.filter(notification => notification.id !== id)
    }

    function hideNotificationPopup(id) {
        removePopup(id)
    }

    function expireNotification(id) {
        const item = notifications.find(notification => notification.id === id)
        if (!item)
            return
        hideNotificationPopup(id)
    }

    function clearNotifications() {
        const current = notifications
        visiblePopups = []
        pendingPopupQueue = []
        notifications = []
        notificationsOpen = false
        for (const item of current) {
            if (item.native && typeof item.native.dismiss === "function")
                item.native.dismiss()
        }
    }

    function expireNotificationPopups() {
        const now = Date.now()
        const expired = visiblePopups.filter(id => {
            const item = notifications.find(notification => notification.id === id)
            return item && item.popup && now - Number(item.createdAt || now) >= 3000
        })
        for (const id of expired)
            expireNotification(id)
    }

    function addNotification(summary, body, urgency) {
        const item = { id: ++notificationSerial, nativeId: 0, native: null,
                       appName: "Quickshell", appIcon: "", summary: String(summary || "Notification"),
                       body: String(body || ""), urgency: urgency === "critical" ? 2 : 1,
                       actions: [], popup: true, closed: false, resident: false,
                       expireTimeout: 5000, image: "", hints: {}, createdAt: Date.now() }
        notifications = [item].concat(notifications).slice(0, 50)
        enqueuePopup(item.id)
    }

    function addSystemNotification(notification) {
        const existing = notifications.find(item => item.nativeId === notification.id)
        const item = { id: existing ? existing.id : ++notificationSerial,
                       nativeId: notification.id, native: notification,
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
        notifications = [item].concat(notifications.filter(old => old.id !== item.id)).slice(0, 50)
        enqueuePopup(item.id)
    }

    function syncNativeNotifications(active) {
        const ids = active.map(notification => notification.id)
        const retained = notifications.filter(item => !item.native || ids.includes(item.nativeId))
        if (retained.length !== notifications.length) notifications = retained
        const retainedIds = retained.map(item => item.id)
        visiblePopups = visiblePopups.filter(id => retainedIds.includes(id))
        pendingPopupQueue = pendingPopupQueue.filter(id => retainedIds.includes(id))
        promotePopupQueue()
    }
}

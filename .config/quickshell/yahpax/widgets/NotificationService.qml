import QtQuick
import Quickshell.Services.Notifications
import "../core" as Core

// Quickshell owns org.freedesktop.Notifications for this session. The
// service object receives native notifications and keeps the backend data
// path available to non-visual Yahpax services.
NotificationServer {
    keepOnReload: true
    bodySupported: true
    bodyMarkupSupported: true
    bodyHyperlinksSupported: true
    bodyImagesSupported: true
    actionsSupported: true
    actionIconsSupported: true
    imageSupported: true
    inlineReplySupported: true

    onNotification: notification => {
        notification.tracked = true
        Core.AppState.addSystemNotification(notification)
    }

    onTrackedNotificationsChanged: {
        Core.AppState.syncNativeNotifications(trackedNotifications.values)
    }
}

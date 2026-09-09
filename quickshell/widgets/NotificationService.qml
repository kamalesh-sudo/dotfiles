import QtQuick
import Quickshell.Services.Notifications
import "../core" as Core

// Quickshell owns org.freedesktop.Notifications for this session. The
// service object receives native notifications and AppState remains the
// single data path used by both the popup and the BarMorph menu.
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

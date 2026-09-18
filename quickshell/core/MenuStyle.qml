pragma Singleton
import QtQuick

QtObject {
    readonly property color panelColor: Qt.rgba(Colors.background.r, Colors.background.g, Colors.background.b, 0.92)
    readonly property color morphPanelColor: Qt.rgba(
        Colors.background.r * 0.90 + Colors.foreground.r * 0.10,
        Colors.background.g * 0.90 + Colors.foreground.g * 0.10,
        Colors.background.b * 0.90 + Colors.foreground.b * 0.10,
        0.22)
    readonly property color subtleSurfaceColor: Qt.rgba(1, 1, 1, 0.05)
    readonly property color hoverSurfaceColor: Qt.rgba(1, 1, 1, 0.12)
    readonly property color notificationSurfaceColor: Qt.rgba(1, 1, 1, 0.06)
    readonly property color inputSurfaceColor: Qt.rgba(1, 1, 1, 0.08)
    readonly property color accentSurfaceColor: Qt.rgba(Colors.accent.r, Colors.accent.g, Colors.accent.b, 0.16)
    readonly property color borderColor: Colors.accent
    readonly property color textColor: Colors.foreground
    readonly property color mutedColor: Colors.muted
    readonly property color accentColor: Colors.accent
    readonly property color overlayColor: "#000000"
    readonly property real overlayOpacity: 0.45
    readonly property int radius: 16
    readonly property int cardRadius: 10
    readonly property int thumbnailRadius: 26
    readonly property int borderWidth: 1
    readonly property string namespace: "quickshell-bar"
}

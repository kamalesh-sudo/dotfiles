pragma Singleton
import QtQuick

QtObject {
    id: root

    // QQmlEasing's BezierSpline enum value in the installed Qt 6 runtime.
    readonly property int bezierSplineType: 44

    // Caelestia-compatible animation tokens. These are the actual reference
    // values: expressive spatial 350/500/650 ms and effects 150/200/300 ms.
    readonly property int hoverDuration: expressiveFastEffectsDuration
    readonly property int pressDuration: expressiveFastEffectsDuration
    readonly property int toggleDuration: expressiveFastSpatialDuration
    readonly property int openDuration: expressiveDefaultSpatialDuration
    readonly property int closeDuration: expressiveDefaultSpatialDuration
    readonly property int expandDuration: expressiveDefaultSpatialDuration
    readonly property int collapseDuration: expressiveDefaultSpatialDuration
    readonly property int popupDuration: normalDuration
    readonly property int stateDuration: expressiveDefaultEffectsDuration
    readonly property int expandedMenuWidth: 900

    readonly property int normalDuration: 400
    readonly property int expressiveFastSpatialDuration: 350
    readonly property int expressiveDefaultSpatialDuration: 500
    readonly property int expressiveSlowSpatialDuration: 650
    readonly property int expressiveFastEffectsDuration: 150
    readonly property int expressiveDefaultEffectsDuration: 200
    readonly property int expressiveSlowEffectsDuration: 300

    // Caelestia's cubic-bezier control points, kept as lists because Yahpax
    // uses QtQuick's Easing.BezierSpline directly.
    readonly property var fastSpatialCurve: [0.42, 1.67, 0.21, 0.9, 1, 1]
    readonly property var defaultSpatialCurve: [0.38, 1.21, 0.22, 1, 1, 1]
    readonly property var slowSpatialCurve: [0.39, 1.29, 0.35, 0.98, 1, 1]
    readonly property var fastEffectsCurve: [0.31, 0.94, 0.34, 1, 1, 1]
    readonly property var defaultEffectsCurve: [0.34, 0.8, 0.34, 1, 1, 1]
    readonly property var slowEffectsCurve: [0.34, 0.88, 0.34, 1, 1, 1]

    readonly property real idleOpacity: 1.0
    readonly property real hoverOpacity: 1.0
    readonly property real pressedOpacity: 0.72
    readonly property real disabledOpacity: 0.45
    readonly property real hoverSurfaceOpacity: 0.12
    readonly property real pressedSurfaceOpacity: 0.20

    readonly property color panelColor: Qt.rgba(Colors.background.r, Colors.background.g, Colors.background.b, 0.92)
    readonly property color morphPanelColor: Qt.rgba(
        Colors.background.r * 0.90 + Colors.foreground.r * 0.10,
        Colors.background.g * 0.90 + Colors.foreground.g * 0.10,
        Colors.background.b * 0.90 + Colors.foreground.b * 0.10, 0.22)
    // One adaptive translucent surface shared by Yahpax shell surfaces. Light
    // wallpapers use the existing dark glass; dark wallpapers use white glass.
    // The compositor blur remains provided by the single quickshell-bar layer.
    readonly property color darkGlobalSurfaceColor: Qt.darker(morphPanelColor, 10)
    readonly property color lightGlobalSurfaceColor: Qt.rgba(1, 1, 1, 0.12)
    readonly property bool useDarkGlobalSurface: !Colors.loaded || Colors.lightBackground
    readonly property color globalSurfaceColor: root.useDarkGlobalSurface
        ? darkGlobalSurfaceColor
        : lightGlobalSurfaceColor
    readonly property color globalBorderColor: root.useDarkGlobalSurface
        ? Qt.rgba(0, 0, 0, 0.18)
        : Qt.rgba(1, 1, 1, 0.12)
    readonly property int globalEdgeThickness: 6
    readonly property color subtleSurfaceColor: Qt.rgba(1, 1, 1, 0.05)
    readonly property color hoverSurfaceColor: Qt.rgba(1, 1, 1, root.hoverSurfaceOpacity)
    readonly property color pressedSurfaceColor: Qt.rgba(1, 1, 1, root.pressedSurfaceOpacity)
    readonly property color notificationSurfaceColor: Qt.rgba(1, 1, 1, 0.06)
    readonly property color inputSurfaceColor: Qt.rgba(1, 1, 1, 0.08)
    readonly property color accentSurfaceColor: Qt.rgba(Colors.accent.r, Colors.accent.g, Colors.accent.b, 0.16)
    readonly property color accentHoverSurfaceColor: Qt.rgba(Colors.accent.r, Colors.accent.g, Colors.accent.b, 0.25)
    readonly property color accentPressedSurfaceColor: Qt.rgba(Colors.accent.r, Colors.accent.g, Colors.accent.b, 0.35)
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
    readonly property int spacingTiny: 2
    readonly property int spacingSmall: 4
    readonly property int spacingMedium: 8
    readonly property int spacingLarge: 12
    readonly property int paddingSmall: 6
    readonly property int paddingMedium: 10
    readonly property int paddingLarge: 14

    // Nested rule objects are the authoritative shared UI contract.
    readonly property QtObject sharedAnimation: QtObject {
        readonly property int duration: root.stateDuration
        readonly property int fastDuration: root.expressiveFastSpatialDuration
        readonly property int slowDuration: root.expressiveSlowSpatialDuration
        readonly property int hoverDuration: root.hoverDuration
        readonly property int pressDuration: root.pressDuration
        readonly property int toggleDuration: root.toggleDuration
        readonly property int openDuration: root.openDuration
        readonly property int closeDuration: root.closeDuration
        readonly property int expandDuration: root.expandDuration
        readonly property int collapseDuration: root.collapseDuration
        readonly property int popupDuration: root.popupDuration
        readonly property var fastSpatialCurve: root.fastSpatialCurve
        readonly property var defaultSpatialCurve: root.defaultSpatialCurve
        readonly property var fastEffectsCurve: root.fastEffectsCurve
        readonly property var defaultEffectsCurve: root.defaultEffectsCurve
        readonly property var slowEffectsCurve: root.slowEffectsCurve
    }
    readonly property QtObject sharedOpacity: QtObject {
        readonly property real idle: root.idleOpacity
        readonly property real hover: root.hoverOpacity
        readonly property real pressed: root.pressedOpacity
        readonly property real disabled: root.disabledOpacity
    }
    readonly property QtObject sharedSurface: QtObject {
        readonly property color panel: root.panelColor
        readonly property color morph: root.morphPanelColor
        readonly property color subtle: root.subtleSurfaceColor
        readonly property color hover: root.hoverSurfaceColor
        readonly property color pressed: root.pressedSurfaceColor
        readonly property color accent: root.accentSurfaceColor
        readonly property color accentHover: root.accentHoverSurfaceColor
        readonly property color accentPressed: root.accentPressedSurfaceColor
        readonly property color notification: root.notificationSurfaceColor
        readonly property color input: root.inputSurfaceColor
        readonly property color border: root.borderColor
    }
    readonly property QtObject sharedSpacing: QtObject {
        readonly property int tiny: root.spacingTiny
        readonly property int small: root.spacingSmall
        readonly property int medium: root.spacingMedium
        readonly property int large: root.spacingLarge
        readonly property int paddingSmall: root.paddingSmall
        readonly property int paddingMedium: root.paddingMedium
        readonly property int paddingLarge: root.paddingLarge
    }
    readonly property QtObject sharedRadius: QtObject {
        readonly property int panel: root.radius
        readonly property int card: root.cardRadius
        readonly property int thumbnail: root.thumbnailRadius
        readonly property int border: root.borderWidth
    }
    readonly property QtObject hoverRule: QtObject {
        readonly property color surface: root.hoverSurfaceColor
        readonly property real opacity: root.hoverOpacity
        readonly property int duration: root.hoverDuration
        readonly property var easing: root.fastEffectsCurve
        readonly property bool expandOnHover: true
        readonly property bool closeOnExit: true
    }
    readonly property QtObject pressedRule: QtObject {
        readonly property color surface: root.pressedSurfaceColor
        readonly property color accentSurface: root.accentPressedSurfaceColor
        readonly property real opacity: root.pressedOpacity
        readonly property int duration: root.pressDuration
        readonly property var easing: root.fastEffectsCurve
    }
    readonly property QtObject activeRule: QtObject {
        readonly property color surface: root.accentSurfaceColor
        readonly property real opacity: root.idleOpacity
        readonly property int duration: root.stateDuration
        readonly property var easing: root.defaultEffectsCurve
    }
    readonly property QtObject inactiveRule: QtObject {
        readonly property color surface: root.subtleSurfaceColor
        readonly property real opacity: root.idleOpacity
        readonly property int duration: root.stateDuration
        readonly property var easing: root.defaultEffectsCurve
    }
    readonly property QtObject toggleRule: QtObject {
        readonly property color offSurface: root.subtleSurfaceColor
        readonly property color onSurface: root.accentSurfaceColor
        readonly property color hoverSurface: root.accentHoverSurfaceColor
        readonly property color pressedSurface: root.accentPressedSurfaceColor
        readonly property real offOpacity: root.idleOpacity
        readonly property real onOpacity: root.idleOpacity
        readonly property real hoverOpacity: root.hoverOpacity
        readonly property real pressedOpacity: root.pressedOpacity
        readonly property int duration: root.toggleDuration
        readonly property var easing: root.fastSpatialCurve
        readonly property var pressEasing: root.fastEffectsCurve
    }
    readonly property QtObject menuTransition: QtObject {
        readonly property int openDuration: root.openDuration
        readonly property int closeDuration: root.closeDuration
        readonly property int expandDuration: root.expandDuration
        readonly property int collapseDuration: root.collapseDuration
        readonly property int popupDuration: root.popupDuration
        readonly property var openEasing: root.defaultSpatialCurve
        readonly property var closeEasing: root.defaultSpatialCurve
        readonly property var expandEasing: root.defaultSpatialCurve
        readonly property var collapseEasing: root.defaultSpatialCurve
    }

    readonly property string namespace: "quickshell-bar"
}

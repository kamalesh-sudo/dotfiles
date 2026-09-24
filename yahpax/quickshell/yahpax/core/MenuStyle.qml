pragma Singleton
import QtQuick

// This file is the single customization point for Yahpax. UI/layout/timing
// values should be changed here rather than inside individual components.

QtObject {
    id: root

    // QQmlEasing's BezierSpline enum value in the installed Qt 6 runtime.
    // Qt easing enum used by Yahpax's cubic-bezier animations.
    readonly property int bezierSplineType: 44

    // Caelestia-compatible animation tokens. These are the actual reference
    // values: expressive spatial 350/500/650 ms and effects 150/200/300 ms.
    // Hover highlight transition used by all controls.
    readonly property int hoverDuration: expressiveFastEffectsDuration
    // Press feedback transition used by all controls.
    readonly property int pressDuration: expressiveFastEffectsDuration
    // Toggle state transition used by buttons and menus.
    readonly property int toggleDuration: expressiveFastSpatialDuration
    // Menu opening transition duration.
    readonly property int openDuration: expressiveDefaultSpatialDuration
    // Menu closing transition duration.
    readonly property int closeDuration: expressiveDefaultSpatialDuration
    // BarMorph expansion transition duration.
    readonly property int expandDuration: expressiveDefaultSpatialDuration
    // BarMorph collapse transition duration.
    readonly property int collapseDuration: expressiveDefaultSpatialDuration
    // Automatic popup movement/fade duration.
    readonly property int popupDuration: normalDuration
    // Generic active/inactive state transition duration.
    readonly property int stateDuration: expressiveDefaultEffectsDuration
    // Shared expanded menu width used by BarMorph and menu-sized surfaces.
    readonly property int expandedMenuWidth: menu.expandedWidth

    // Fallback duration for ordinary Yahpax transitions, in milliseconds.
    readonly property int normalDuration: 400
    // Fast reveal/reposition duration, in milliseconds.
    readonly property int expressiveFastSpatialDuration: 350
    // Standard menu open/close and resize duration, in milliseconds.
    readonly property int expressiveDefaultSpatialDuration: 500
    // Slow, deliberate spatial transition duration, in milliseconds.
    readonly property int expressiveSlowSpatialDuration: 650
    // Fast hover/press opacity duration, in milliseconds.
    readonly property int expressiveFastEffectsDuration: 150
    // Standard opacity/state transition duration, in milliseconds.
    readonly property int expressiveDefaultEffectsDuration: 200
    // Slow opacity/state transition duration, in milliseconds.
    readonly property int expressiveSlowEffectsDuration: 300

    // Caelestia's cubic-bezier control points, kept as lists because Yahpax
    // uses QtQuick's Easing.BezierSpline directly.
    // Curve for fast bar reveal and compact spatial movement.
    readonly property var fastSpatialCurve: [0.42, 1.67, 0.21, 0.9, 1, 1]
    // Curve for ordinary menu expansion/collapse.
    readonly property var defaultSpatialCurve: [0.38, 1.21, 0.22, 1, 1, 1]
    // Curve for deliberately slow spatial movement.
    readonly property var slowSpatialCurve: [0.39, 1.29, 0.35, 0.98, 1, 1]
    // Curve for hover and press opacity feedback.
    readonly property var fastEffectsCurve: [0.31, 0.94, 0.34, 1, 1, 1]
    // Curve for ordinary visibility/state effects.
    readonly property var defaultEffectsCurve: [0.34, 0.8, 0.34, 1, 1, 1]
    // Curve for slow visibility/state effects.
    readonly property var slowEffectsCurve: [0.34, 0.88, 0.34, 1, 1, 1]

    // Opacity of an enabled control at rest.
    readonly property real idleOpacity: 1.0
    // Opacity of a hovered control.
    readonly property real hoverOpacity: 1.0
    // Opacity of a pressed control.
    readonly property real pressedOpacity: 0.72
    // Opacity of a disabled control.
    readonly property real disabledOpacity: 0.45
    // Overlay opacity used by hovered controls.
    readonly property real hoverSurfaceOpacity: 0.12
    // Overlay opacity used by pressed controls.
    readonly property real pressedSurfaceOpacity: 0.20

    // Base opaque panel tint used by non-global menu surfaces.
    readonly property color panelColor: Colors.panelBackground
    // Base translucent tint used by the expanded BarMorph surface.
    readonly property color morphPanelColor: Colors.panelBackground
    // One adaptive translucent surface shared by Yahpax shell surfaces. Light
    // wallpapers use the existing dark glass; dark wallpapers use white glass.
    // The compositor blur remains provided by the single quickshell-bar layer.
    readonly property color darkGlobalSurfaceColor: Colors.blurMaskColor
    readonly property color lightGlobalSurfaceColor: Colors.blurMaskColor
    readonly property bool useDarkGlobalSurface: !Colors.loaded || !Colors.panelIsLight
    readonly property color globalSurfaceColor: Colors.blurMaskColor
    readonly property color globalBorderColor: Colors.border
    // Screen space reserved by each GlobalShellLayer edge surface.
    readonly property int globalEdgeThickness: blur.edgeThickness
    // Low-contrast surface used by inactive controls.
    readonly property color subtleSurfaceColor: Colors.widgetBackground
    // Hover overlay used by buttons and list rows.
    readonly property color hoverSurfaceColor: Colors.widgetHover
    // Pressed overlay used by buttons and list rows.
    readonly property color pressedSurfaceColor: Colors.widgetPressed
    // Default notification-card surface tint.
    readonly property color notificationSurfaceColor: Colors.widgetBackground
    // Input/search field surface tint.
    readonly property color inputSurfaceColor: Colors.widgetBackground
    // Active/accent control surface tint.
    readonly property color accentSurfaceColor: Colors.accentSoftSurface
    // Hovered active/accent control surface tint.
    readonly property color accentHoverSurfaceColor: Colors.accentStrongSurface
    // Pressed active/accent control surface tint.
    readonly property color accentPressedSurfaceColor: Colors.accentStrongSurface
    // Border color used by shell panels and interactive controls.
    readonly property color borderColor: Colors.border
    // Primary text color used by shared shell controls.
    readonly property color textColor: Colors.primaryText
    // Secondary text color used by labels and metadata.
    readonly property color mutedColor: Colors.mutedText
    // Accent color used by active controls and indicators.
    readonly property color accentColor: Colors.accent
    // Base color used by modal overlay surfaces.
    readonly property color overlayColor: "#000000"
    // Opacity of the dark overlay behind modal menu content.
    readonly property real overlayOpacity: 0.45

    // Shared sharp-cut distance used by bar and menu silhouettes.
    readonly property int radius: 16
    // Corner radius used by small rectangular cards.
    readonly property int cardRadius: 10
    // Radius used by thumbnail/icon surfaces.
    readonly property int thumbnailRadius: 26
    // Shared border thickness for shell surfaces.
    readonly property int borderWidth: 1
    // Smallest gap between adjacent controls.
    readonly property int spacingTiny: 2
    // Small gap between related controls.
    readonly property int spacingSmall: 4
    // Standard gap between rows and menu items.
    readonly property int spacingMedium: 8
    // Large gap between separate menu sections.
    readonly property int spacingLarge: 12
    // Compact control padding.
    readonly property int paddingSmall: 6
    // Standard card/menu padding.
    readonly property int paddingMedium: 10
    // Outer panel padding.
    readonly property int paddingLarge: 14

    // Main bar dimensions and reveal geometry.
    readonly property QtObject bar: QtObject {
        // Extra pixels added below the palette-defined bar height.
        readonly property real heightExtra: 3
        // Maximum width of the fixed bar host.
        readonly property real hostMaxWidth: 880
        // Minimum width of the fixed bar host.
        readonly property real hostMinWidth: 900
        // Extra host height reserved for expanded menu content.
        readonly property real hostHeightExtra: 380
        // Maximum corner-cut radius used by expanded BarMorph surfaces.
        readonly property real expandedRadiusCap: 20
        // Top inset of the inner bar content surface.
        readonly property real surfaceTopInset: 2
        // Bottom inset of the inner bar content surface.
        readonly property real surfaceBottomInset: 1
        // Top inset of the bar inside the global shell.
        readonly property real topOffset: 5
        // Width ratio of the invisible top-edge reveal zone.
        readonly property real revealZoneWidthRatio: 0.50
        // Height of the invisible top-edge reveal zone.
        readonly property real revealZoneHeight: 10
        // Vertical offset of the reveal zone above the bar host.
        readonly property real revealZoneOffset: -5
        // Width ratio used by the collapsed BarMorph.
        readonly property real collapsedWidthRatio: 0.300
        // Maximum collapsed BarMorph width.
        readonly property real collapsedWidthMax: 880
        // Horizontal padding around the bar's icon row.
        readonly property real contentSidePadding: 18
        // Height offset used by the workspace indicator.
        readonly property real workspaceHeightOffset: 17
        // Width of the trailing bar-side cluster.
        readonly property real sideClusterWidth: 220
        // Height of compact bar action buttons.
        readonly property real actionHeightOffset: 10
        // Width of compact bar action buttons.
        readonly property real actionWidth: 30
    }

    // Expanded menu dimensions used by BarMorph and related panels.
    readonly property QtObject menu: QtObject {
        // Standard launcher/expanded-menu width.
        readonly property real expandedWidth: 900
        // Launcher menu height beyond the bar row.
        readonly property real launcherHeight: 380
        // Clipboard menu width.
        readonly property real clipboardWidth: 560
        // Clipboard menu height.
        readonly property real clipboardHeight: 380
        // Wi-Fi menu width.
        readonly property real wifiWidth: 480
        // Wi-Fi menu height.
        readonly property real wifiHeight: 300
        // Bluetooth menu width.
        readonly property real bluetoothWidth: 480
        // Bluetooth menu height.
        readonly property real bluetoothHeight: 300
        // Wallpaper selector width ratio relative to the screen.
        readonly property real wallpaperWidthRatio: 0.5
        // Maximum wallpaper selector width.
        readonly property real wallpaperMaxWidth: 720
        // Wallpaper selector height beyond the bar row.
        readonly property real wallpaperHeight: 80
        // Compact fallback menu width.
        readonly property real compactWidth: 280
        // Compact fallback menu height.
        readonly property real compactHeight: 90
    }

    // Dock layout metrics.
    readonly property QtObject dock: QtObject {
        // Screen inset for the dock's left edge.
        readonly property real screenInset: 1
        // Width of each dock entry body.
        readonly property real buttonWidth: 300
        // Height of the dock entry body.
        readonly property real buttonHeight: 60
        // Dock width added beside the entry column.
        readonly property real widthExtra: 160
        // Dock outer height added around the entry column.
        readonly property real heightExtra: 30
        // Dock content left inset.
        readonly property real contentLeftPadding: 20
        // Gap between dock entries.
        readonly property real entrySpacing: 16
        // Horizontal entry offset used by the stagger effect.
        readonly property real staggerOffset: 17
        // Entry icon width.
        readonly property real iconWidth: 36
        // Entry icon height.
        readonly property real iconHeight: 34
        // Left inset for the dock's icon/text row.
        readonly property real rowLeftPadding: 24
        // Gap between dock icon and text.
        readonly property real rowSpacing: 13
        // Right inset for the dock index label.
        readonly property real indexRightPadding: 16
        // Dock icon hover scale.
        readonly property real hoverScale: 1.05
        // Dock idle entry opacity.
        readonly property real idleEntryOpacity: 0.5
        // Dock entry border thickness.
        readonly property real entryBorderWidth: 1
        // Dock icon label font size.
        readonly property real iconFontSize: 18
        // Dock title font size.
        readonly property real titleFontSize: 15
        // Dock metadata/index font size.
        readonly property real metadataFontSize: 10
        // Dock accent animation duration, in milliseconds.
        readonly property int pulseDuration: 1100
    }

    // Notification panel and individual notification card metrics.
    readonly property QtObject notification: QtObject {
        // Maximum number of simultaneously visible popup cards.
        readonly property int maxVisible: 3
        // Notification Center panel width.
        readonly property real panelWidth: 350
        // Maximum Notification Center height.
        readonly property real maxPanelHeight: 520
        // Minimum Notification Center height while it has content.
        readonly property real minPanelHeight: 180
        // Vertical screen padding used to calculate available panel height.
        readonly property real screenPadding: -0
        // Refresh interval for relative notification timestamps.
        readonly property int clockRefreshInterval: 5000
        // Right/top screen offset before attachment to the bar.
        readonly property real edgeMargin: 16
        // Automatic popup lifetime, in milliseconds.
        readonly property int popupDuration: 3000
        // Notification icon container size.
        readonly property real iconSize: 38
        // Notification action button height.
        readonly property real actionHeight: 26
        // Notification dismiss button size.
        readonly property real dismissSize: 24
        // Notification Center header text size.
        readonly property real headerFontSize: 15
        // Notification application/timestamp text size.
        readonly property real metadataFontSize: 10
        // Notification summary text size.
        readonly property real summaryFontSize: 12
        // Notification body text size.
        readonly property real bodyFontSize: 11
        // Notification fallback bell icon size.
        readonly property real fallbackIconFontSize: 16
        // Notification chevron icon size.
        readonly property real chevronFontSize: 12
        // Notification Center clear icon size.
        readonly property real clearFontSize: 13
        // Notification dismiss icon size.
        readonly property real dismissFontSize: 11
        // Notification action label text size.
        readonly property real actionFontSize: 10
        // Notification icon image inset.
        readonly property real iconInset: 5
        // Notification Center clear button size.
        readonly property real clearButtonSize: 30
        // Notification body row spacing when no section gap is needed.
        readonly property real compactRowSpacing: 0
        // Maximum expanded body lines.
        readonly property int bodyMaxLines: 12
        // Maximum compact body preview lines.
        readonly property int previewMaxLines: 1
    }

    // Shared popup attachment and movement metrics.
    readonly property QtObject popup: QtObject {
        // Initial vertical offset before a popup settles into place.
        readonly property real entryOffset: -18
        // Distance required to swipe a popup away.
        readonly property real swipeThreshold: 0.4
        // Vertical drag distance required to expand a popup.
        readonly property real expandThreshold: 16
        // Horizontal multiplier used when removing a popup.
        readonly property real removalDistance: 2
        // Extra hit area around the notification expand chevron.
        readonly property real chevronHitSlop: -8
    }

    // Surface/blur customization values. The actual compositor blur remains
    // provided by the existing quickshell-bar namespace rule.
    readonly property QtObject blur: QtObject {
        // Namespace used by Yahpax's shared blurred shell surface.
        readonly property string namespace: "quickshell-bar"
        // Screen edge thickness associated with the blurred layer.
        readonly property real edgeThickness: 6
    }

    // Shared layout offsets used by screen-attached components.
    readonly property QtObject layout: QtObject {
        // Main bar's top screen offset.
        readonly property real barTopOffset: 5
        // Global exclusion surface's minimum extent.
        readonly property real exclusionExtent: 1
        // Fallback screen width used by off-screen morph calculations.
        readonly property real defaultScreenWidth: 1920
        // Fallback screen height used by off-screen morph calculations.
        readonly property real defaultScreenHeight: 1080
        // Todo-board geometry and placement metrics.
        readonly property QtObject todo: QtObject {
            // Width of each todo card.
            readonly property real cardWidth: 300
            // Height of each todo card.
            readonly property real cardHeight: 60
            // Gap between todo cards.
            readonly property real gap: 16
            // Outer todo-board padding.
            readonly property real margin: 20
            // Top offset below the shell bar.
            readonly property real topOffset: 92
            // Right offset from the screen edge.
            readonly property real rightOffset: 28
            // Maximum number of todo entries displayed.
            readonly property int maxVisible: 6
            // Periodic todo reminder check interval, in milliseconds.
            readonly property int reminderInterval: 60000
            // Todo card content left inset.
            readonly property real contentLeftPadding: 24
            // Todo card content right inset.
            readonly property real contentRightPadding: 14
            // Gap between todo card rows.
            readonly property real rowSpacing: 13
            // Width reserved for todo title text.
            readonly property real titleWidth: 220
            // Todo completion button size.
            readonly property real completeButtonSize: 22
            // Todo title font size.
            readonly property real titleFontSize: 15
            // Todo metadata font size.
            readonly property real metadataFontSize: 10
            // Todo completion icon font size.
            readonly property real completeFontSize: 16
        }
    }

    // Input/reveal interaction thresholds.
    readonly property QtObject input: QtObject {
        // Minimum reveal progress considered visible to the input mask.
        readonly property real visibleThreshold: 0.001
        // Reveal-zone stacking order above the bar content.
        readonly property int revealZoneZ: 100
    }

    // Nested rule objects are the authoritative shared UI contract.
    readonly property QtObject sharedAnimation: QtObject {
        // Default duration for shared UI state transitions.
        readonly property int duration: root.stateDuration
        // Fast duration for reveal and compact spatial movement.
        readonly property int fastDuration: root.expressiveFastSpatialDuration
        // Slow duration for deliberate spatial movement.
        readonly property int slowDuration: root.expressiveSlowSpatialDuration
        // Hover highlight transition duration.
        readonly property int hoverDuration: root.hoverDuration
        // Press feedback transition duration.
        readonly property int pressDuration: root.pressDuration
        // Toggle transition duration.
        readonly property int toggleDuration: root.toggleDuration
        // Menu opening transition duration.
        readonly property int openDuration: root.openDuration
        // Menu closing transition duration.
        readonly property int closeDuration: root.closeDuration
        // BarMorph expansion transition duration.
        readonly property int expandDuration: root.expandDuration
        // BarMorph collapse transition duration.
        readonly property int collapseDuration: root.collapseDuration
        // Notification popup movement/fade duration.
        readonly property int popupDuration: root.popupDuration
        // Cubic-bezier curve for fast spatial movement.
        readonly property var fastSpatialCurve: root.fastSpatialCurve
        // Cubic-bezier curve for ordinary spatial movement.
        readonly property var defaultSpatialCurve: root.defaultSpatialCurve
        // Cubic-bezier curve for hover/press effects.
        readonly property var fastEffectsCurve: root.fastEffectsCurve
        // Cubic-bezier curve for ordinary state effects.
        readonly property var defaultEffectsCurve: root.defaultEffectsCurve
        // Cubic-bezier curve for slow state effects.
        readonly property var slowEffectsCurve: root.slowEffectsCurve
    }
    readonly property QtObject sharedOpacity: QtObject {
        // Resting opacity for enabled controls.
        readonly property real idle: root.idleOpacity
        // Hover opacity for controls under the pointer.
        readonly property real hover: root.hoverOpacity
        // Pressed opacity while a control is activated.
        readonly property real pressed: root.pressedOpacity
        // Opacity for disabled controls.
        readonly property real disabled: root.disabledOpacity
    }
    readonly property QtObject sharedSurface: QtObject {
        // Opaque panel surface used by compact menus.
        readonly property color panel: root.panelColor
        // Translucent surface used by the expanded bar morph.
        readonly property color morph: root.morphPanelColor
        // Low-contrast inactive control surface.
        readonly property color subtle: root.subtleSurfaceColor
        // Hover surface overlay used by controls and rows.
        readonly property color hover: root.hoverSurfaceColor
        // Pressed surface overlay used by controls and rows.
        readonly property color pressed: root.pressedSurfaceColor
        // Active/accent surface used by selected controls.
        readonly property color accent: root.accentSurfaceColor
        // Hovered active/accent surface.
        readonly property color accentHover: root.accentHoverSurfaceColor
        // Pressed active/accent surface.
        readonly property color accentPressed: root.accentPressedSurfaceColor
        // Surface used by notification cards.
        readonly property color notification: root.notificationSurfaceColor
        // Surface used by search and input fields.
        readonly property color input: root.inputSurfaceColor
        // Shared shell border color.
        readonly property color border: root.borderColor
    }
    readonly property QtObject sharedSpacing: QtObject {
        // Minimum gap between adjacent controls.
        readonly property int tiny: root.spacingTiny
        // Small gap between related controls.
        readonly property int small: root.spacingSmall
        // Standard gap between rows and menu items.
        readonly property int medium: root.spacingMedium
        // Large gap between menu sections.
        readonly property int large: root.spacingLarge
        // Compact control padding.
        readonly property int paddingSmall: root.paddingSmall
        // Standard card/menu padding.
        readonly property int paddingMedium: root.paddingMedium
        // Outer panel padding.
        readonly property int paddingLarge: root.paddingLarge
    }
    readonly property QtObject sharedRadius: QtObject {
        // Shared panel corner-cut distance.
        readonly property int panel: root.radius
        // Radius for small rectangular cards.
        readonly property int card: root.cardRadius
        // Radius for thumbnails and icon surfaces.
        readonly property int thumbnail: root.thumbnailRadius
        // Shared shell border thickness.
        readonly property int border: root.borderWidth
    }
    readonly property QtObject hoverRule: QtObject {
        // Surface shown while a control is hovered.
        readonly property color surface: root.hoverSurfaceColor
        // Opacity applied while a control is hovered.
        readonly property real opacity: root.hoverOpacity
        // Hover transition duration.
        readonly property int duration: root.hoverDuration
        // Hover transition easing curve.
        readonly property var easing: root.fastEffectsCurve
        // Whether a hovered control reveals its attached content.
        readonly property bool expandOnHover: true
        // Whether leaving a control collapses its attached content.
        readonly property bool closeOnExit: true
    }
    readonly property QtObject pressedRule: QtObject {
        // Surface shown while a control is pressed.
        readonly property color surface: root.pressedSurfaceColor
        // Accent surface shown while an active control is pressed.
        readonly property color accentSurface: root.accentPressedSurfaceColor
        // Opacity applied while a control is pressed.
        readonly property real opacity: root.pressedOpacity
        // Press transition duration.
        readonly property int duration: root.pressDuration
        // Press transition easing curve.
        readonly property var easing: root.fastEffectsCurve
    }
    readonly property QtObject activeRule: QtObject {
        // Surface used by active or selected controls.
        readonly property color surface: root.accentSurfaceColor
        // Opacity used by active controls.
        readonly property real opacity: root.idleOpacity
        // Active-state transition duration.
        readonly property int duration: root.stateDuration
        // Active-state transition easing curve.
        readonly property var easing: root.defaultEffectsCurve
    }
    readonly property QtObject inactiveRule: QtObject {
        // Surface used by inactive controls.
        readonly property color surface: root.subtleSurfaceColor
        // Opacity used by inactive controls.
        readonly property real opacity: root.idleOpacity
        // Inactive-state transition duration.
        readonly property int duration: root.stateDuration
        // Inactive-state transition easing curve.
        readonly property var easing: root.defaultEffectsCurve
    }
    readonly property QtObject toggleRule: QtObject {
        // Surface used when a toggle is off.
        readonly property color offSurface: root.subtleSurfaceColor
        // Surface used when a toggle is on.
        readonly property color onSurface: root.accentSurfaceColor
        // Surface used when an on-toggle is hovered.
        readonly property color hoverSurface: root.accentHoverSurfaceColor
        // Surface used while a toggle is pressed.
        readonly property color pressedSurface: root.accentPressedSurfaceColor
        // Opacity used when a toggle is off.
        readonly property real offOpacity: root.idleOpacity
        // Opacity used when a toggle is on.
        readonly property real onOpacity: root.idleOpacity
        // Opacity used while a toggle is hovered.
        readonly property real hoverOpacity: root.hoverOpacity
        // Opacity used while a toggle is pressed.
        readonly property real pressedOpacity: root.pressedOpacity
        // Toggle state transition duration.
        readonly property int duration: root.toggleDuration
        // Toggle state easing curve.
        readonly property var easing: root.fastSpatialCurve
        // Toggle press easing curve.
        readonly property var pressEasing: root.fastEffectsCurve
    }
    readonly property QtObject menuTransition: QtObject {
        // Menu opening duration.
        readonly property int openDuration: root.openDuration
        // Menu closing duration.
        readonly property int closeDuration: root.closeDuration
        // BarMorph expansion duration.
        readonly property int expandDuration: root.expandDuration
        // BarMorph collapse duration.
        readonly property int collapseDuration: root.collapseDuration
        // Popup movement/fade duration.
        readonly property int popupDuration: root.popupDuration
        // Menu opening easing curve.
        readonly property var openEasing: root.defaultSpatialCurve
        // Menu closing easing curve.
        readonly property var closeEasing: root.defaultSpatialCurve
        // BarMorph expansion easing curve.
        readonly property var expandEasing: root.defaultSpatialCurve
        // BarMorph collapse easing curve.
        readonly property var collapseEasing: root.defaultSpatialCurve
    }

    // Namespace shared by all Yahpax blurred shell surfaces.
    readonly property string namespace: blur.namespace
}

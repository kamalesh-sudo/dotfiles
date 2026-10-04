pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

QtObject {
    id: root

    // Single source of truth for Yahpax colors and wallpaper contrast.
    // Components should consume these semantic colors instead of deciding
    // light/dark behavior locally.

    // Generated pywal palette consumed by the Yahpax theme.
    readonly property string jsonPath: Quickshell.env("HOME") + "/.cache/yahpax/wal/colors.json"
    // Primary UI font used by body text, labels, menus, and notifications.
    // Noto Sans is available system-wide and matches Caelestia's sans UI role.
    readonly property string fontFamily: "Noto Sans"
    // Monospace font reserved for code-like or terminal content.
    readonly property string monoFontFamily: "JetBrainsMono Nerd Font"
    // Nerd Font used by Yahpax icon glyphs.
    readonly property string iconFontFamily: "Symbols Nerd Font"
    // Normal body weight used by ordinary labels and content.
    readonly property int bodyWeight: Font.Normal
    // Medium weight used by compact labels and metadata headings.
    readonly property int labelWeight: Font.Medium
    // DemiBold weight used by titles and prominent summaries.
    readonly property int titleWeight: Font.DemiBold
    // Normal icon weight used to keep glyphs from looking heavy.
    readonly property int iconWeight: Font.Normal
    // Compatibility alias for older body-text consumers.
    readonly property int textWeight: Font.Normal
    // Opacity of the modal overlay behind menus.
    readonly property real overlayOpacity: 0.7
    // Base color for modal overlays behind menu content.
    readonly property color overlayColor: "#000000"
    // Color basis for every shared blurred shell/panel surface.
    readonly property color sharedSurfaceColor: fillInactive

    // Fallback wallpaper background while the generated palette is loading.
    property color walBackground: "#0d0d0d"
    // Fallback palette foreground retained for generated-theme compatibility.
    property color walForeground: "#e0e0e0"
    // Cursor color supplied by the generated palette.
    property color walCursor: "#e0e0e0"
    // Sixteen generated palette colors used for accents and sampling.
    property var walPalette: ["#0d0d0d", "#cc6666", "#b5bd68", "#f0c674",
        "#81a2be", "#b294bb", "#8abeb7", "#e0e0e0", "#3a3a3a",
        "#cc6666", "#b5bd68", "#f0c674", "#81a2be", "#b294bb",
        "#8abeb7", "#ffffff"]

    // Lower hysteresis threshold used when leaving light-panel mode.
    readonly property real lightToDarkThreshold: 0.44
    // Upper hysteresis threshold used when entering light-panel mode.
    readonly property real darkToLightThreshold: 0.56
    // Minimum accent-to-panel contrast ratio accepted for accents.
    readonly property real minimumAccentContrast: 2.0

    // Current panel treatment selected from the trimmed palette luminance.
    property string surfaceMode: "dark"
    // Robust luminance sample from generated palette and wallpaper color.
    property real wallpaperSampleLuminance: 0.0
    // Compatibility state name reflecting the sampled surface decision.
    readonly property string wallpaperLightness: surfaceMode
    // True when the selected panel treatment is light.
    readonly property bool lightBackground: surfaceMode === "light"

    // Raw wallpaper/background color from the generated palette.
    readonly property color background: walBackground
    // Cursor color from the generated palette.
    readonly property color cursor: walCursor
    // Generated palette exposed to widgets using palette accents.
    readonly property var palette: walPalette

    // Dark panel base used over light or colorful wallpapers.
    readonly property color darkPanelBackground: Qt.rgba(
        Math.max(0.035, background.r * 0.22),
        Math.max(0.035, background.g * 0.22),
        Math.max(0.035, background.b * 0.22), 0.94)
    // Light panel base used over dark wallpapers.
    readonly property color lightPanelBackground: Qt.rgba(0.92, 0.93, 0.96, 0.86)
    // Effective panel surface used by every Yahpax shell surface.
    readonly property color panelBackground: lightBackground
        ? lightPanelBackground : darkPanelBackground
    // Material-style base surface role used by panels.
    readonly property color surface: panelBackground
    // Opacity of the translucent tint laid over compositor-blurred wallpaper.
    // This is intentionally independent from text/icon opacity.
    readonly property real blurMaskOpacity: 0.14
    // Adaptive foreground-derived tint used by the shared blur surfaces.
    // It is never pure black or pure white.
    readonly property color blurMaskColor: Qt.rgba(
        primaryText.r, primaryText.g, primaryText.b, blurMaskOpacity)
    // Panel luminance used to select readable text and icons.
    readonly property real panelLuminance: relativeLuminance(panelBackground)
    // True when the effective panel surface needs dark content.
    readonly property bool panelIsLight: panelLuminance >= 0.50

    // Slightly separated widget surface inside the main panel.
    readonly property color widgetBackground: blend(panelBackground, primaryText, panelIsLight ? 0.07 : 0.12)
    // Higher-contrast container surface used by selected/raised widgets.
    readonly property color surfaceContainer: widgetBackground
    // Stronger container surface used by hover and pressed states.
    readonly property color surfaceContainerHigh: widgetHover
    // Hover surface used by buttons and list rows.
    readonly property color widgetHover: blend(widgetBackground, primaryText, panelIsLight ? 0.10 : 0.16)
    // Pressed surface used by buttons and list rows.
    readonly property color widgetPressed: blend(widgetBackground, primaryText, panelIsLight ? 0.16 : 0.23)
    // Primary readable text: true black on light panels, true white on dark panels.
    readonly property color primaryText: panelIsLight ? "#000000" : "#FFFFFF"
    // Material-style on-surface role used by primary text and icons.
    readonly property color onSurface: primaryText
    // Secondary text: the same binary foreground at reduced opacity.
    readonly property color secondaryText: Qt.rgba(primaryText.r, primaryText.g, primaryText.b, panelIsLight ? 0.70 : 0.76)
    // Muted text: the same binary foreground at lower opacity.
    readonly property color mutedText: Qt.rgba(primaryText.r, primaryText.g, primaryText.b, panelIsLight ? 0.45 : 0.56)
    // Material-style on-surface-variant role used by secondary metadata.
    readonly property color onSurfaceVariant: secondaryText
    // Icon color selected from the effective panel surface.
    readonly property color icon: primaryText
    // Border color with contrast against the panel surface.
    readonly property color border: blend(panelBackground, primaryText, panelIsLight ? 0.34 : 0.28)
    // Material-style outline role used by borders.
    readonly property color outline: border
    // Separator color used between rows and sections.
    readonly property color separator: blend(panelBackground, primaryText, panelIsLight ? 0.22 : 0.18)
    // Faint separator overlay used on panel edges and card tops.
    readonly property color separatorOverlay: Qt.rgba(primaryText.r, primaryText.g, primaryText.b, panelIsLight ? 0.18 : 0.33)
    // Soft accent surface used by icons and selected controls.
    readonly property color accentSoftSurface: Qt.rgba(accent.r, accent.g, accent.b, panelIsLight ? 0.14 : 0.28)
    // Faint accent surface used by idle controls.
    readonly property color accentFaintSurface: Qt.rgba(accent.r, accent.g, accent.b, panelIsLight ? 0.08 : 0.14)
    // Strong accent surface used by hovered or pressed controls.
    readonly property color accentStrongSurface: Qt.rgba(accent.r, accent.g, accent.b, panelIsLight ? 0.24 : 0.36)
    // Contrast-safe active accent chosen from the generated palette.
    readonly property color accent: contrastSafeAccent()
    // Contrast-safe secondary accent used by indicators.
    readonly property color accent2: contrastSafeSecondaryAccent()
    // Text color used on accent-filled controls.
    readonly property color accentText: relativeLuminance(accent) >= 0.50
        ? Qt.rgba(0.03, 0.035, 0.05, 1) : Qt.rgba(0.98, 0.99, 1, 1)
    // Text color placed on active workspace/accent markers.
    readonly property color activeMarkerText: accentText

    // Canonical Dock-derived inactive button fill.
    readonly property color fillInactive: accentFaintSurface
    // Canonical Dock-derived active/hover button fill.
    readonly property color fillActive: accentSoftSurface
    // Canonical Dock-derived pressed button fill.
    readonly property color fillPressed: accentStrongSurface
    // Canonical Dock-derived border color for active controls.
    readonly property color borderColor: accent
    // Canonical Dock-derived readable text color.
    readonly property color textColor: primaryText
    // Dock uses the accent specifically for icon glyphs.
    readonly property color iconColor: accent

    // Track whether the generated palette has loaded successfully.
    property bool loaded: false

    // Perceptual luminance for a #RRGGBB/#RGB generated color. This uses
    // sRGB linearization and Rec.709 weights, not a raw RGB average.
    function hexLuminance(value) {
        if (typeof value !== "string") return 0.5
        var text = value.trim()
        if (text.charAt(0) === "#") text = text.slice(1)
        if (text.length === 3) text = text[0] + text[0] + text[1] + text[1] + text[2] + text[2]
        if (text.length < 6) return 0.5
        var r = parseInt(text.slice(0, 2), 16) / 255
        var g = parseInt(text.slice(2, 4), 16) / 255
        var b = parseInt(text.slice(4, 6), 16) / 255
        function linear(channel) {
            return channel <= 0.04045 ? channel / 12.92 : Math.pow((channel + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * linear(r) + 0.7152 * linear(g) + 0.0722 * linear(b)
    }

    // Read luminance from generated strings or QML colors.
    function sampledLuminance(value) {
        if (typeof value === "string") return hexLuminance(value)
        if (value && value.r !== undefined) {
            function linear(channel) {
                return channel <= 0.04045 ? channel / 12.92 : Math.pow((channel + 0.055) / 1.055, 2.4)
            }
            return 0.2126 * linear(value.r) + 0.7152 * linear(value.g) + 0.0722 * linear(value.b)
        }
        return 0.5
    }

    // Trim extreme palette colors and sample the middle population so one
    // unusually bright/dark swatch cannot flip the shell treatment.
    function calculateWallpaperSample() {
        var samples = [hexLuminance(walBackground), hexLuminance(walBackground)]
        for (var i = 0; i < walPalette.length; ++i) samples.push(sampledLuminance(walPalette[i]))
        samples.sort(function(a, b) { return a - b })
        var trim = Math.floor(samples.length * 0.20)
        var start = trim
        var end = Math.max(start + 1, samples.length - trim)
        var total = 0
        for (var j = start; j < end; ++j) total += samples[j]
        return total / (end - start)
    }

    // Hysteresis prevents theme reloads near the boundary from flickering.
    function updateSurfaceMode(sample) {
        wallpaperSampleLuminance = sample
        if (surfaceMode === "light") {
            if (sample <= lightToDarkThreshold) surfaceMode = "dark"
        } else if (sample >= darkToLightThreshold) {
            surfaceMode = "light"
        }
    }

    // Blend two semantic surfaces into one opaque QML color.
    function blend(base, overlay, amount) {
        return Qt.rgba(base.r * (1 - amount) + overlay.r * amount,
                       base.g * (1 - amount) + overlay.g * amount,
                       base.b * (1 - amount) + overlay.b * amount, 1)
    }

    // Relative luminance of a QML color with sRGB linearization.
    function relativeLuminance(value) {
        return sampledLuminance(value)
    }

    // WCAG-style contrast ratio used to reject unreadable accent colors.
    function contrastRatio(first, second) {
        var high = Math.max(relativeLuminance(first), relativeLuminance(second))
        var low = Math.min(relativeLuminance(first), relativeLuminance(second))
        return (high + 0.05) / (low + 0.05)
    }

    // Prefer generated accents, falling back to readable panel text.
    function contrastSafeAccent() {
        var primary = palette.length > 4 ? palette[4] : "#81a2be"
        var secondary = palette.length > 6 ? palette[6] : "#8abeb7"
        if (contrastRatio(primary, panelBackground) >= minimumAccentContrast) return primary
        if (contrastRatio(secondary, panelBackground) >= minimumAccentContrast) return secondary
        return primaryText
    }

    // Choose a distinct secondary accent without sacrificing readability.
    function contrastSafeSecondaryAccent() {
        var candidate = palette.length > 6 ? palette[6] : "#8abeb7"
        if (contrastRatio(candidate, panelBackground) >= minimumAccentContrast) return candidate
        return accent
    }

    property FileView walFile: FileView {
        path: root.jsonPath
        watchChanges: true
        blockLoading: false
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.parse(text())
    }

    // Retry loading the generated palette while the theme pipeline starts.
    property Timer retry: Timer {
        interval: 1000
        running: !root.loaded
        repeat: true
        onTriggered: root.walFile.reload()
    }

    function parse(raw) {
        if (!raw) return
        try {
            var data = JSON.parse(raw)
            if (data.special) {
                walBackground = data.special.background || walBackground
                walForeground = data.special.foreground || walForeground
                walCursor = data.special.cursor || walCursor
            }
            if (data.colors) {
                var next = []
                for (var i = 0; i < 16; ++i)
                    next.push(data.colors["color" + i] || walPalette[i])
                walPalette = next
            }
            updateSurfaceMode(calculateWallpaperSample())
            loaded = true
            console.info("Colors: sample=" + wallpaperSampleLuminance.toFixed(3)
                         + " mode=" + surfaceMode
                         + " panelLuminance=" + panelLuminance.toFixed(3))
        } catch (e) {
            console.warn("Colors: failed to parse colors.json", e)
        }
    }
}

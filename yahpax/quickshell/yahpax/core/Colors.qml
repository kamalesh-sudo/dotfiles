pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

QtObject {
    id: root
    readonly property string jsonPath: Quickshell.env("HOME") + "/.cache/yahpax/wal/colors.json"
    readonly property string lightnessPath: Quickshell.env("HOME") + "/.cache/yahpax/rice/wallpaper-lightness"
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int textWeight: Font.DemiBold
    readonly property int radius: 16
    readonly property int borderWidth: 1
    readonly property int barHeight: 40
    readonly property real overlayOpacity: 0.7
    property color walBackground: "#0d0d0d"
    property color walForeground: "#e0e0e0"
    property color walCursor: "#e0e0e0"
    property var walPalette: ["#0d0d0d","#cc6666","#b5bd68","#f0c674","#81a2be","#b294bb","#8abeb7","#e0e0e0","#3a3a3a","#cc6666","#b5bd68","#f0c674","#81a2be","#b294bb","#8abeb7","#ffffff"]
    readonly property color background: walBackground
    readonly property real backgroundLuminance: 0.2126 * background.r
                                                    + 0.7152 * background.g
                                                    + 0.0722 * background.b
    property string wallpaperLightness: "dark"
    readonly property bool lightBackground: wallpaperLightness === "light"
    readonly property color foreground: lightBackground ? "#050509" : "#f5f7ff"
    readonly property color cursor: walCursor
    readonly property var palette: walPalette
    readonly property color accent: palette[4]
    readonly property color accent2: palette[6]
    readonly property color muted: lightBackground ? "#303038" : "#b8bfcc"
    property bool loaded: false
    property FileView walFile: FileView {
        path: root.jsonPath; watchChanges: true; blockLoading: false; printErrors: false
        onFileChanged: reload()
        onLoaded: root.parse(text())
    }
    property FileView lightnessFile: FileView {
        path: root.lightnessPath; watchChanges: true; blockLoading: false; printErrors: false
        onFileChanged: reload()
        onLoaded: {
            root.wallpaperLightness = text().trim() === "light" ? "light" : "dark"
            console.info("Colors: wallpaperLightness=" + root.wallpaperLightness)
        }
    }
    property Timer retry: Timer { interval: 1000; running: !root.loaded; repeat: true; onTriggered: root.walFile.reload() }
    function parse(raw) {
        if (!raw) return
        try {
            const data = JSON.parse(raw)
            if (data.special) {
                walBackground = data.special.background || walBackground
                walForeground = data.special.foreground || walForeground
                walCursor = data.special.cursor || walCursor
            }
            if (data.colors) {
                const next = []
                for (let i = 0; i < 16; ++i) next.push(data.colors["color" + i] || walPalette[i])
                walPalette = next
            }
            loaded = true
            console.info("Colors: background=" + background
                         + " luminance=" + backgroundLuminance.toFixed(3)
                         + " wallpaperLightness=" + wallpaperLightness
                         + " light=" + lightBackground
                         + " foreground=" + foreground
                         + " muted=" + muted
                         + " weight=" + textWeight)
        } catch (e) { console.warn("Colors: failed to parse colors.json", e) }
    }
}

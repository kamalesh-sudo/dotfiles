import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../core" as Core
import ".." as Local

Item {
    id: root

    property var modelData
    property real normalWidth: Core.MenuStyle.bar.collapsedWidthMax * Core.MenuStyle.bar.collapsedWidthRatio
    property real normalHeight: Core.Colors.barHeight + Core.MenuStyle.bar.heightExtra
    property var enabledModes: ["launcher", "clipboard", "bluetooth", "wifi", "wallpaper"]
    readonly property bool onThisScreen: Core.AppState.morphScreenName === (modelData ? modelData.name : "")
    readonly property bool expanded: enabledModes.indexOf(Core.AppState.barMorph) >= 0
                                      && Core.AppState.barMorph !== "" && onThisScreen
    property bool hoverSurfaceEntered: false

    onExpandedChanged: {
        if (!expanded)
            hoverSurfaceEntered = false
    }
    readonly property var expandedSize: root.targetSize(Core.AppState.barMorph, modelData ? modelData.width : Core.MenuStyle.layout.defaultScreenWidth)
    readonly property real expandedWidth: expandedSize.w
    readonly property real expandedHeight: expandedSize.h + normalHeight
    readonly property real visualRadius: expanded
        ? Math.min(height / 2, Core.MenuStyle.bar.expandedRadiusCap)
        : normalHeight / 2

    width: expanded ? expandedWidth : normalWidth
    height: expanded ? expandedHeight : normalHeight

    Behavior on width {
        NumberAnimation {
            duration: root.expanded
                ? Core.MenuStyle.menuTransition.expandDuration
                : Core.MenuStyle.menuTransition.collapseDuration
            easing.type: Core.MenuStyle.bezierSplineType
            easing.bezierCurve: root.expanded
                ? Core.MenuStyle.menuTransition.expandEasing
                : Core.MenuStyle.menuTransition.collapseEasing
        }
    }
    Behavior on height {
        NumberAnimation {
            duration: root.expanded
                ? Core.MenuStyle.menuTransition.expandDuration
                : Core.MenuStyle.menuTransition.collapseDuration
            easing.type: Core.MenuStyle.bezierSplineType
            easing.bezierCurve: root.expanded
                ? Core.MenuStyle.menuTransition.expandEasing
                : Core.MenuStyle.menuTransition.collapseEasing
        }
    }

    // Desktop entries are stable for the lifetime of the shell. Keep the
    // sorted base list on the persistent BarMorph instead of rebuilding it
    // every time the launcher Loader is created.
    readonly property var launcherApplications: {
        const all = [...DesktopEntries.applications.values].filter(d => d.name);
        all.sort((a, b) => a.name.localeCompare(b.name));
        return all;
    }

    function targetSize(name, screenWidth) {
        switch (name) {
            case "wallpaper":   return { w: Math.min(screenWidth * Core.MenuStyle.menu.wallpaperWidthRatio, Core.MenuStyle.menu.wallpaperMaxWidth), h: Core.MenuStyle.menu.wallpaperHeight };
            case "launcher":    return { w: Core.MenuStyle.menu.expandedWidth, h: Core.MenuStyle.menu.launcherHeight };
            case "clipboard":   return { w: Core.MenuStyle.menu.clipboardWidth, h: Core.MenuStyle.menu.clipboardHeight };
            case "wifi":        return { w: Core.MenuStyle.menu.wifiWidth, h: Core.MenuStyle.menu.wifiHeight };
            case "bluetooth":   return { w: Core.MenuStyle.menu.bluetoothWidth, h: Core.MenuStyle.menu.bluetoothHeight };
            default:            return { w: Core.MenuStyle.menu.compactWidth, h: Core.MenuStyle.menu.compactHeight };
        }
    }

    Core.SharpShape {
        id: panel
        anchors.fill: parent
        // The global screen Shape owns the continuous outer surface and
        // border. Keeping this item transparent preserves clipping/input for
        // the existing BarMorph content without drawing a second outline.
        cutBottomLeft: true
        cutBottomRight: true
        cutAmount: Core.MenuStyle.radius
        fillColor: "transparent"
        strokeWidth: 0
        MouseArea {
            anchors { left: parent.left; right: parent.right; top: barContent.bottom; bottom: parent.bottom }
            enabled: root.expanded
            onClicked: Core.AppState.closeMorph()
        }

        HoverHandler {
            id: morphHover
            enabled: root.expanded && Core.MenuStyle.hoverRule.closeOnExit
            onHoveredChanged: {
                if (hovered) {
                    root.hoverSurfaceEntered = true
                } else if (root.hoverSurfaceEntered) {
                    Core.AppState.closeMorph()
                }
            }
        }

        Item {
            id: barContent
            z: 1
            width: root.width
            height: root.normalHeight
            // The collapsed bar and expanded island share this visual root.
            // Once expanded, remove the old bar visuals and input from the
            // surface instead of allowing them to show through the island.
            opacity: root.expanded ? 0 : 1
            enabled: !root.expanded
            property var modelData: root.modelData
            signal morphTriggered(string name)
            onMorphTriggered: root.openMode(name, root.modelData)

            readonly property real screenWidth: modelData ? modelData.width : Core.MenuStyle.layout.defaultScreenWidth
            readonly property real screenHeight: modelData ? modelData.height : Core.MenuStyle.layout.defaultScreenHeight

            function triggerMorph(name) {
                const screenName = modelData ? modelData.name : "";
                if (Core.AppState.barMorph === name && Core.AppState.morphScreenName === screenName) {
                    Core.AppState.closeMorph();
                    return;
                }
                morphTriggered(name);
            }

            function triggerHoverMorph(name) {
                if (name === "power" || !Core.MenuStyle.hoverRule.expandOnHover || root.expanded)
                    return;
                if (Core.AppState.barMorph === "") {
                    root.hoverSurfaceEntered = false;
                    morphTriggered(name);
                }
            }

            Rectangle {
                id: barBg
                anchors.fill: parent
                                anchors.topMargin: Core.MenuStyle.bar.surfaceTopInset
                                anchors.bottomMargin: Core.MenuStyle.bar.surfaceBottomInset
                opacity: Core.AppState.barTemporarilyHidden ? 0 : 1
                radius: height / 2
                color: "transparent"
                border.width: 0

                RowLayout {
                    id: barRow
                    anchors.fill: parent
                                    anchors.leftMargin: Core.MenuStyle.bar.contentSidePadding
                                    anchors.rightMargin: Core.MenuStyle.bar.contentSidePadding
                    spacing: 0

                    Item {
                        Layout.preferredWidth: barRow.sideWidth
                        Layout.fillHeight: true
                        Item {
                            id: workspaces
                            anchors.verticalCenter: parent.verticalCenter
                            readonly property int cellWidth: 26
                            readonly property int cellHeight: 22
                            readonly property int cellSpacing: 2
                            readonly property int unit: cellWidth + cellSpacing
                            readonly property int configuredWorkspaceCount: 5
                            readonly property var workspaceList: {
                                const current = Hyprland.workspaces.values || [];
                                return Array.from({ length: configuredWorkspaceCount }, (_, i) => {
                                    const id = i + 1;
                                    const workspace = current.find(w => w.id === id);
                                    return { id: id, occupied: workspace ? workspace.windows > 0 : false };
                                });
                            }
                            width: configuredWorkspaceCount * unit - cellSpacing
                            height: cellHeight
                            readonly property int activeIndex: {
                                const focusedId = Hyprland.focusedWorkspace?.id ?? 0;
                                const index = workspaceList.findIndex(w => w.id === focusedId);
                                return index >= 0 ? index : 0;
                            }
                            property int previousIndex: 0
                            Component.onCompleted: previousIndex = activeIndex
                            property real blobX: activeIndex * unit
                            onActiveIndexChanged: {
                                previousIndex = activeIndex;
                                blobX = activeIndex * unit;
                            }
                            Rectangle { x: workspaces.blobX; width: workspaces.cellWidth; height: Local.Colors.barHeight - 17; radius: height / 2; color: Core.MenuStyle.toggleRule.offSurface }
                            Row {
                                spacing: workspaces.cellSpacing
                                Repeater {
                                    model: workspaces.workspaceList
                                    Item {
                                        width: workspaces.cellWidth
                                        height: workspaces.cellHeight
                                        readonly property int workspaceNumber: modelData.id
                                        readonly property bool isActive: index === workspaces.activeIndex
                                        readonly property bool isOccupied: modelData.occupied
                                        Text { anchors.centerIn: parent; text: workspaceNumber; font.family: Local.Colors.fontFamily; font.pixelSize: 12; font.weight: isActive ? Font.Bold : Local.Colors.bodyWeight; color: Local.Colors.icon; opacity: isActive ? 1.0 : (isOccupied ? 0.85 : 0.35) }
                                        MouseArea { anchors.fill: parent; onClicked: Hyprland.dispatch("workspace " + workspaceNumber) }
                                    }
                                }
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Text {
                            id: clockCenter
                            anchors.centerIn: parent
                            color: Local.Colors.foreground
                            font.family: Local.Colors.fontFamily
                            font.pixelSize: 13
                            font.weight: Local.Colors.labelWeight
                            property string currentTime: Qt.formatDateTime(new Date(), "h:mm AP")
                            text: currentTime
                            Timer { interval: 1000 * 15; running: true; repeat: true; onTriggered: clockCenter.currentTime = Qt.formatDateTime(new Date(), "h:mm AP") }
                        }
                    }

                    Item {
                        Layout.preferredWidth: barRow.sideWidth
                        Layout.fillHeight: true
                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            spacing: Core.MenuStyle.sharedSpacing.small
                            Repeater {
                                model: [
                                    { glyph: "\uf1eb", morph: "wifi" },
                                    { glyph: "\uf294", morph: "bluetooth" },
                                    { glyph: "\uf011", morph: "power" }
                                ]
                                Rectangle {
                                    width: 30
                                    height: Local.Colors.barHeight - 10
                                    radius: height / 2
                                    color: barIconMouse.pressed
                                           ? Core.MenuStyle.toggleRule.pressedSurface
                                           : (Core.AppState.barMorph === modelData.morph && Core.AppState.morphScreenName === (barContent.modelData ? barContent.modelData.name : ""))
                                             ? Core.MenuStyle.toggleRule.onSurface
                                             : barIconMouse.containsMouse ? Core.MenuStyle.toggleRule.hoverSurface : Core.MenuStyle.toggleRule.offSurface
                                    Behavior on color {
                                        ColorAnimation {
                                            duration: Core.MenuStyle.hoverRule.duration
                                            easing.type: Core.MenuStyle.bezierSplineType
                                            easing.bezierCurve: Core.MenuStyle.sharedAnimation.fastEffectsCurve
                                        }
                                    }
                                    Text { anchors.centerIn: parent; text: modelData.glyph; font.family: Local.Colors.iconFontFamily; font.pixelSize: 13; color: Local.Colors.icon }
                                    MouseArea {
                                        id: barIconMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onEntered: barContent.triggerHoverMorph(modelData.morph)
                                        onClicked: modelData.morph === "power"
                                            ? Core.AppState.togglePowerMenu()
                                            : barContent.triggerMorph(modelData.morph)
                                    }
                                }
                            }
                        }
                    }
                    property real sideWidth: Core.MenuStyle.bar.sideClusterWidth
                }
            }
        }

        Loader {
            id: contentLoader
            z: 3
            x: 12
            y: 12
            width: Math.max(0, parent.width - 24)
            height: Math.max(0, parent.height - 24)
            active: root.expanded
            sourceComponent: {
                switch (Core.AppState.barMorph) {
                    case "wallpaper": return wallpaperContent;
                    case "launcher": return launcherContent;
                    case "clipboard": return clipboardContent;
                    case "bluetooth": return bluetoothContent;
                    case "wifi": return wifiPanelContent;
                    default: return stubContent;
                }
            }
        }
    }

    Connections {
        target: Core.AppState
        function onMorphRequested(name) {
            if (root.enabledModes.indexOf(name) < 0) return;
            if (Quickshell.screens.length > 1) {
                const mon = Hyprland.focusedMonitor;
                if (mon && root.modelData && mon.name !== root.modelData.name) return;
            }
            root.openMode(name, root.modelData);
        }
    }

    Component {
        id: wifiPanelContent
        Local.WifiPanel {}
    }

            Component {
                id: launcherContent
                Item {
                    id: laRoot
                    anchors.fill: parent
                    property string query: ""
                    property int selIndex: 0

                    readonly property var apps: {
                        const q = query.trim().toLowerCase();
                        if (q === "") return root.launcherApplications;
                        return root.launcherApplications.filter(d => (d.name || "").toLowerCase().includes(q)
                                            || (d.comment || "").toLowerCase().includes(q));
                    }
                    onQueryChanged: selIndex = 0

                    Column {
                        anchors.fill: parent
                        spacing: 8

                        Rectangle {
                            width: parent.width
                            height: 34
                            radius: height / 2
                            color: Core.MenuStyle.inputSurfaceColor
                            border.color: Core.Colors.accent
                            border.width: Core.MenuStyle.borderWidth

                            TextInput {
                                id: laInput
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                verticalAlignment: TextInput.AlignVCenter
                                color: Core.Colors.foreground
                                    font.family: Core.Colors.fontFamily
                                    font.pixelSize: 13
                                    font.weight: Core.Colors.bodyWeight
                                clip: true
                                onTextChanged: laRoot.query = text
                                Component.onCompleted: forceActiveFocus()

                                Keys.onPressed: (event) => {
                                    if (event.key === Qt.Key_Up) {
                                        laRoot.selIndex = Math.max(0, laRoot.selIndex - 1);
                                        laList.positionViewAtIndex(laRoot.selIndex, ListView.Contain);
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Down) {
                                        laRoot.selIndex = Math.max(0, Math.min(laRoot.apps.length - 1, laRoot.selIndex + 1));
                                        laList.positionViewAtIndex(laRoot.selIndex, ListView.Contain);
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                        const raw = laRoot.query.trim();
                                        if (raw.startsWith(">")) {
                                            Quickshell.execDetached(["sh", "-c", raw.slice(1).trim()]);
                                            Core.AppState.closeMorph();
                                        } else if (laRoot.apps.length > 0) {
                                            laRoot.apps[laRoot.selIndex].execute();
                                            Core.AppState.closeMorph();
                                        }
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Escape) {
                                        Core.AppState.closeMorph();
                                        event.accepted = true;
                                    }
                                }
                            }
                        }

                        ListView {
                            id: laList
                            width: parent.width
                            height: parent.height - 42
                            clip: true
                            model: laRoot.apps
                            currentIndex: laRoot.selIndex
                            onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                            delegate: Rectangle {
                                width: laList.width
                                height: 34
                                radius: height / 2
                                color: index === laRoot.selIndex
                                       ? Core.Colors.accentSoftSurface
                                       : "transparent"
                                Row {
                                    anchors.verticalCenter: parent.verticalCenter
                                    x: 12
                                    spacing: 10
                                    Image {
                                        id: appIcon
                                        width: 20; height: 20
                                        anchors.verticalCenter: parent.verticalCenter
                                        property string iconName: {
                                            const raw = String(modelData.icon || "");
                                            const basename = raw.slice(raw.lastIndexOf("/") + 1);
                                            return basename.replace(/\.(svg|png|xpm)$/i, "");
                                        }
                                        property string candyIconName: {
                                            const aliases = { burpsuite: "burp" };
                                            return aliases[iconName] || iconName;
                                        }
                                        property string fallbackSource: modelData.icon
                                            ? Quickshell.iconPath(modelData.icon, true) : ""
                                        property int candyAttempt: 0
                                        property bool candyFailed: iconName.length === 0
                                        readonly property var candySources: [
                                            "file:///usr/share/icons/candy-icons/apps/scalable/" + candyIconName + ".svg",
                                            "file:///usr/share/icons/candy-icons/apps/scalable/" + candyIconName + ".png"
                                        ]
                                        source: candyFailed ? fallbackSource : candySources[candyAttempt]
                                        asynchronous: true
                                        sourceSize.width: 20
                                        sourceSize.height: 20
                                        // Launcher delegates are destroyed when the
                                        // Loader closes; do not retain every decoded
                                        // application icon in the global image cache.
                                        cache: false
                                        onStatusChanged: {
                                            if (status !== Image.Error) return;
                                            if (candyAttempt + 1 < candySources.length) candyAttempt += 1;
                                            else candyFailed = true;
                                        }
                                    }
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: modelData.name
                                        color: Core.Colors.foreground
                                        font.family: Core.Colors.fontFamily
                                        font.pixelSize: 13
                                        font.weight: Core.Colors.bodyWeight
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: laRoot.selIndex = index
                                    onClicked: {
                                        modelData.execute();
                                        Core.AppState.closeMorph();
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Component {
                id: clipboardContent
                Item {
                    id: chRoot
                    anchors.fill: parent
                    property var items: []
                    property int selIndex: 0
                    focus: true
                    onItemsChanged: selIndex = 0
                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Up) {
                            selIndex = Math.max(0, selIndex - 1);
                            chList.positionViewAtIndex(selIndex, ListView.Contain);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Down) {
                            selIndex = Math.max(0, Math.min(items.length - 1, selIndex + 1));
                            chList.positionViewAtIndex(selIndex, ListView.Contain);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (items.length > 0) {
                                Quickshell.execDetached(["fish",
                                    Quickshell.env("HOME") + "/.config/quickshell/yahpax/scripts/cliphist-restore.fish",
                                    items[selIndex]]);
                                Core.AppState.closeMorph();
                            }
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Escape) {
                            Core.AppState.closeMorph();
                            event.accepted = true;
                        }
                    }

                    Process {
                        id: chLister
                        command: ["cliphist", "list"]
                        running: true
                        stdout: StdioCollector {
                            onStreamFinished: {
                                chRoot.items = this.text.split("\n")
                                    .filter(l => l.trim().length > 0).slice(0, 60);
                            }
                        }
                    }

                    Column {
                        anchors.fill: parent
                        spacing: 8

                        Text {
                            text: "Clipboard"
                            color: Core.Colors.foreground
                            font.family: Core.Colors.fontFamily
                            font.pixelSize: 12
                            font.weight: Core.Colors.bodyWeight
                        }

                        ListView {
                            id: chList
                            width: parent.width
                            height: parent.height - 24
                            clip: true
                            spacing: 4
                            model: chRoot.items
                            currentIndex: chRoot.selIndex
                            onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                            delegate: Rectangle {
                                width: chList.width
                                height: 30
                                radius: height / 2
                                color: chMouse.containsMouse || index === chRoot.selIndex
                                       ? Core.Colors.accentSoftSurface
                                       : Core.MenuStyle.subtleSurfaceColor
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    x: 14
                                    width: parent.width - 28
                                    elide: Text.ElideRight
                                    text: modelData.split("\t").slice(1).join(" ")
                                    color: Core.Colors.foreground
                                    font.family: Core.Colors.fontFamily
                                    font.pixelSize: 11
                                    font.weight: Core.Colors.bodyWeight
                                }

                                MouseArea {
                                    id: chMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: chRoot.selIndex = index
                                    onClicked: {
                                        Quickshell.execDetached(["fish",
                                    Quickshell.env("HOME") + "/.config/quickshell/yahpax/scripts/cliphist-restore.fish",
                                            modelData]);
                                        Core.AppState.closeMorph();
                                    }
                                }
                            }
                        }
                    }
                }
            }
            

            Component {
                id: wallpaperContent
                Column {
                    id: wpRoot
                    anchors.fill: parent
                    spacing: Core.MenuStyle.spacingMedium
                    focus: true

                    property var items: []
                    property int selIndex: 0

                    Component.onCompleted: forceActiveFocus()

                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Right || event.key === Qt.Key_L) {
                            selIndex = Math.min(selIndex + 1, items.length - 1);
                            wpList.positionViewAtIndex(selIndex, ListView.Center);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Left || event.key === Qt.Key_H) {
                            selIndex = Math.max(0, selIndex - 1);
                            wpList.positionViewAtIndex(selIndex, ListView.Center);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (items.length > 0) wpRoot.applyWallpaper(items[selIndex].path);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Escape) {
                            Core.AppState.closeMorph();
                            event.accepted = true;
                        }
                    }

                    function applyWallpaper(path) {
                        const posX = Math.round(Core.AppState.morphOriginX
                                                 + Core.AppState.morphOriginWidth / 2);
                        const posY = Math.round(Core.AppState.morphScreenHeight
                                                 - Core.AppState.morphOriginY);
                        Core.AppState.closeMorph();
                        Core.AppState.hideBarTemporarily(1500);
                        Quickshell.execDetached(["fish",
                            Quickshell.env("HOME") + "/.config/quickshell/yahpax/scripts/apply-wallpaper.fish",
                            path, "grow", posX + "," + posY]);
                    }

                    Process {
                        id: wpLister
                        command: ["fish",
                            Quickshell.env("HOME") + "/.config/quickshell/yahpax/scripts/wallpaper-list-thumbnails.fish"]
                        running: true
                        stdout: StdioCollector {
                            onStreamFinished: {
                                wpRoot.items = this.text.split("\n")
                                    .filter(l => l.length > 0)
                                    .map(l => {
                                        const parts = l.split("\t");
                                        return { path: parts[0], thumb: parts[1] || parts[0] };
                                    });
                            }
                        }
                    }

                    Text {
                        text: "Wallpapers"
                        color: Core.Colors.foreground
                        font.family: Core.Colors.fontFamily
                        font.pixelSize: 12
                        font.weight: Core.Colors.bodyWeight
                    }

                    ListView {
                      id: wpList
                      width: parent.width
                      height: parent.height - 24
                      orientation: ListView.Horizontal
                      spacing: 10
                      clip: true
                      cacheBuffer: 400
                      model: wpRoot.items
                      currentIndex: wpRoot.selIndex
                      highlightMoveDuration: 120
                      onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Center)

                      delegate: Item {
                        width: 122; height: 66
                        Rectangle {
                                  id: card
                                  width: 122; height: 66
                                  radius: Core.MenuStyle.thumbnailRadius
                                  clip: true
                                  color: "transparent"
                                  border.width: index === wpRoot.selIndex ? 2 : 1
                                  border.color: index === wpRoot.selIndex ? Core.Colors.accent : Core.Colors.muted

                                  Image {
                                        id: thumb
                                        anchors.fill: parent
                                        anchors.margins: 2
                                        source: "file://" + modelData.thumb
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: false
                                        cache: true
                                        sourceSize.width: 244
                                        sourceSize.height: 132
                                        visible: true
                                    }
                                    Rectangle {
                                        id: maskShape
                                        anchors.fill: thumb
                                        radius: card.radius - 2
                                        visible: false
                                    }
                                    OpacityMask {
                                        anchors.fill: thumb
                                        source: thumb
                                        maskSource: maskShape
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: { wpRoot.selIndex = index; wpRoot.applyWallpaper(modelData.path); }
                                    }
                                }
                        }
                    }
                  }
                }

            Component {
                id: bluetoothContent
                Local.BluetoothPanel {}
            }

            Component {
                id: stubContent
                Item {
                    anchors.fill: parent
                    Column {
                        anchors.centerIn: parent
                        spacing: 4
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "\uf013"
                        font.family: Core.Colors.iconFontFamily
                            font.pixelSize: 18
                            color: Core.Colors.muted
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "under construction"
                            font.family: Core.Colors.fontFamily
                            font.pixelSize: 11
                        font.weight: Core.Colors.bodyWeight
                            color: Core.Colors.muted
                        }
                    }
                }
            }

    function openMode(name, screen) {
        if (root.enabledModes.indexOf(name) < 0) return;
        const screenName = screen ? screen.name : "";
        if (Core.AppState.barMorph === name && Core.AppState.morphScreenName === screenName) {
            Core.AppState.closeMorph();
            return;
        }
        const width = Math.min(Core.MenuStyle.bar.collapsedWidthMax, (screen ? screen.width : Core.MenuStyle.layout.defaultScreenWidth) * Core.MenuStyle.bar.collapsedWidthRatio);
        Core.AppState.openMorph(name,
            ((screen ? screen.width : Core.MenuStyle.layout.defaultScreenWidth) - width) / 2,
            0,
            width,
            root.normalHeight,
            screenName,
            screen ? screen.height : Core.MenuStyle.layout.defaultScreenHeight);
    }
}

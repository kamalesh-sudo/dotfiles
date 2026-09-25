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
    property real normalHeight: Core.MenuStyle.bar.baseHeight + Core.MenuStyle.bar.heightExtra
    property var enabledModes: ["launcher", "clipboard", "bluetooth", "wifi", "wallpaper"]
    readonly property bool onThisScreen: Core.AppState.morphScreenName === (modelData ? modelData.name : "")
    readonly property bool expanded: enabledModes.indexOf(Core.AppState.barMorph) >= 0
                                      && Core.AppState.barMorph !== "" && onThisScreen
    property bool hoverSurfaceEntered: false
    focus: expanded

    function handleSelectorKey(key) {
        if (!expanded || !contentLoader.item) return false;
        if (key === Qt.Key_Escape) {
            Core.AppState.closeMorph();
            return true;
        }
        if (contentLoader.item.handleKey)
            return contentLoader.item.handleKey(key);
        return false;
    }

    Keys.onPressed: (event) => {
        if (root.handleSelectorKey(event.key)) event.accepted = true;
    }

    onExpandedChanged: {
        if (!expanded) {
            hoverSurfaceEntered = false
        } else {
            // `focus: true` only makes the item focusable. Claim focus after
            // the Loader has been activated so keys also work when the mode
            // was opened while another application had focus.
            Qt.callLater(function() {
                if (!root.expanded) return;
                if (contentLoader.item && contentLoader.item.forceActiveFocus)
                    contentLoader.item.forceActiveFocus();
                else
                    root.forceActiveFocus();
            });
        }
    }

    Component.onCompleted: {
        if (expanded) forceActiveFocus();
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
                            readonly property int cellWidth: Core.MenuStyle.bar.workspaceCellWidth
                            readonly property int cellHeight: Core.MenuStyle.bar.workspaceCellHeight
                            readonly property int cellSpacing: Core.MenuStyle.bar.workspaceSpacing
                            readonly property int unit: cellWidth + cellSpacing
                            readonly property int configuredWorkspaceCount: Core.MenuStyle.bar.workspaceCount
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
                            Behavior on blobX {
                                NumberAnimation {
                                    duration: Core.MenuStyle.workspaceSwitchDuration
                                    easing.type: Easing.OutCubic
                                }
                            }
                            onActiveIndexChanged: {
                                previousIndex = activeIndex;
                                blobX = activeIndex * unit;
                            }
                            Rectangle {
                                x: workspaces.blobX
                            width: Core.MenuStyle.bar.workspaceCellWidth
                                height: Core.MenuStyle.bar.baseHeight - Core.MenuStyle.bar.workspaceHeightOffset
                                radius: height / 2
                                // Keep the active workspace marker exactly
                                // matched to its own dynamic border color.
                                color: Core.MenuStyle.dockButtonRule.activeSurface
                                border.width: Core.MenuStyle.sharedRadius.border
                                border.color: Core.Colors.borderColor
                            }
                            Row {
                                spacing: Core.MenuStyle.bar.workspaceSpacing
                                Repeater {
                                    model: workspaces.workspaceList
                                    Item {
                                        width: Core.MenuStyle.bar.workspaceCellWidth
                                        height: Core.MenuStyle.bar.workspaceCellHeight
                                        readonly property int workspaceNumber: modelData.id
                                        readonly property bool isActive: index === workspaces.activeIndex
                                        readonly property bool isOccupied: modelData.occupied
                                        Text { anchors.centerIn: parent; text: workspaceNumber; font.family: Local.Colors.fontFamily; font.pixelSize: Core.MenuStyle.bar.workspaceFontSize; font.weight: isActive ? Font.Bold : Local.Colors.bodyWeight; color: Local.Colors.icon; opacity: isActive ? Core.MenuStyle.bar.workspaceActiveOpacity : (isOccupied ? Core.MenuStyle.bar.workspaceOccupiedOpacity : Core.MenuStyle.bar.workspaceEmptyOpacity) }
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
                            color: Local.Colors.secondaryText
                            font.family: Local.Colors.fontFamily
                            font.pixelSize: Core.MenuStyle.bar.clockFontSize
                            font.weight: Local.Colors.labelWeight
                            property string currentTime: Qt.formatDateTime(new Date(), "h:mm AP")
                            text: currentTime
                            Timer { interval: Core.MenuStyle.bar.clockRefreshInterval; running: true; repeat: true; onTriggered: clockCenter.currentTime = Qt.formatDateTime(new Date(), "h:mm AP") }
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
                                    width: Core.MenuStyle.bar.actionWidth
                                    height: Core.MenuStyle.bar.baseHeight - Core.MenuStyle.bar.actionHeightOffset
                                    radius: height / 2
                                    border.width: Core.MenuStyle.sharedRadius.border
                                    border.color: Core.Colors.borderColor
                                    color: barIconMouse.pressed
                                           ? Core.MenuStyle.dockButtonRule.pressedSurface
                                           : (barIconMouse.containsMouse
                                              || (Core.AppState.barMorph === modelData.morph
                                                  && Core.AppState.morphScreenName === (barContent.modelData ? barContent.modelData.name : "")))
                                             ? Core.MenuStyle.dockButtonRule.activeSurface
                                             : Core.MenuStyle.dockButtonRule.idleSurface
                                    Behavior on color {
                                        ColorAnimation {
                                            duration: Core.MenuStyle.hoverRule.duration
                                            easing.type: Core.MenuStyle.bezierSplineType
                                            easing.bezierCurve: Core.MenuStyle.sharedAnimation.fastEffectsCurve
                                        }
                                    }
                                    Text { anchors.centerIn: parent; text: modelData.glyph; font.family: Local.Colors.iconFontFamily; font.pixelSize: Core.MenuStyle.bar.actionGlyphFontSize; color: Local.Colors.secondaryText }
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
            x: Core.MenuStyle.bar.loaderPadding
            y: Core.MenuStyle.bar.loaderPadding
            width: Math.max(0, parent.width - Core.MenuStyle.bar.loaderPadding * 2)
            height: Math.max(0, parent.height - Core.MenuStyle.bar.loaderPadding * 2)
            active: root.expanded
            focus: root.expanded
            onLoaded: {
                if (root.expanded && item && item.forceActiveFocus)
                    Qt.callLater(function() {
                        if (root.expanded && contentLoader.item)
                            contentLoader.item.forceActiveFocus();
                    });
            }
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
                    property int selIndex: -1

                    readonly property var apps: {
                        const q = query.trim().toLowerCase();
                        if (q === "") return root.launcherApplications;
                        return root.launcherApplications.filter(d => (d.name || "").toLowerCase().includes(q)
                                            || (d.comment || "").toLowerCase().includes(q));
                    }
                    function clampSelection() {
                        selIndex = apps.length > 0 ? Math.max(0, Math.min(apps.length - 1, selIndex)) : -1;
                    }

                    function moveSelection(delta) {
                        clampSelection();
                        if (apps.length === 0) return;
                        selIndex = Math.max(0, Math.min(apps.length - 1, selIndex + delta));
                        laList.positionViewAtIndex(selIndex, ListView.Contain);
                    }

                    function handleKey(key) {
                        if (key === Qt.Key_Up) moveSelection(-1);
                        else if (key === Qt.Key_Down) moveSelection(1);
                        else if (key === Qt.Key_Home) {
                            selIndex = apps.length > 0 ? 0 : -1;
                            if (selIndex >= 0) laList.positionViewAtIndex(selIndex, ListView.Beginning);
                        } else if (key === Qt.Key_End) {
                            selIndex = apps.length - 1;
                            if (selIndex >= 0) laList.positionViewAtIndex(selIndex, ListView.End);
                        } else return false;
                        return true;
                    }

                    onQueryChanged: selIndex = apps.length > 0 ? 0 : -1
                    onAppsChanged: clampSelection()

                    Column {
                        anchors.fill: parent
                        spacing: Core.MenuStyle.menu.launcherSpacing

                        Rectangle {
                            width: parent.width
                            height: Core.MenuStyle.menu.launcherInputHeight
                            radius: height / 2
                            color: Core.MenuStyle.inputSurfaceColor
                            border.color: Core.Colors.borderColor
                            border.width: Core.MenuStyle.borderWidth

                            TextInput {
                                id: laInput
                                anchors.fill: parent
                                anchors.leftMargin: Core.MenuStyle.menu.launcherInputPadding
                                anchors.rightMargin: Core.MenuStyle.menu.launcherInputPadding
                                verticalAlignment: TextInput.AlignVCenter
                                color: Core.Colors.textColor
                                    font.family: Core.Colors.fontFamily
                                    font.pixelSize: Core.MenuStyle.menu.launcherFontSize
                                    font.weight: Core.Colors.bodyWeight
                                clip: true
                                onTextChanged: laRoot.query = text
                                Component.onCompleted: forceActiveFocus()

                                Keys.onPressed: (event) => {
                                    if (event.key === Qt.Key_Up) {
                                        laRoot.moveSelection(-1);
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Down) {
                                        laRoot.moveSelection(1);
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Left || event.key === Qt.Key_Right) {
                                        // The launcher is currently a one-column list.
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Home) {
                                        laRoot.selIndex = laRoot.apps.length > 0 ? 0 : -1;
                                        if (laRoot.selIndex >= 0) laList.positionViewAtIndex(laRoot.selIndex, ListView.Beginning);
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_End) {
                                        laRoot.selIndex = laRoot.apps.length - 1;
                                        if (laRoot.selIndex >= 0) laList.positionViewAtIndex(laRoot.selIndex, ListView.End);
                                        event.accepted = true;
                                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                        const raw = laRoot.query.trim();
                                        if (raw.startsWith(">")) {
                                            const command = raw.slice(1).trim();
                                            if (command.length > 0) Quickshell.execDetached(["sh", "-c", command]);
                                            if (command.length > 0) Core.AppState.closeMorph();
                                        } else if (laRoot.selIndex >= 0 && laRoot.selIndex < laRoot.apps.length) {
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
                            height: parent.height - Core.MenuStyle.menu.launcherListReserve
                            clip: true
                            model: laRoot.apps
                            currentIndex: laRoot.selIndex
                            onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                            delegate: Rectangle {
                                width: laList.width
                                height: Core.MenuStyle.menu.launcherItemHeight
                                radius: height / 2
                                color: index === laRoot.selIndex
                                       ? Core.Colors.fillActive
                                       : "transparent"
                                Row {
                                    anchors.verticalCenter: parent.verticalCenter
                                    x: Core.MenuStyle.menu.launcherRowInset
                                    spacing: Core.MenuStyle.sharedSpacing.medium
                                    Image {
                                        id: appIcon
                                        width: Core.MenuStyle.menu.launcherIconSize; height: Core.MenuStyle.menu.launcherIconSize
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
                                        sourceSize.width: Core.MenuStyle.menu.launcherIconSize
                                        sourceSize.height: Core.MenuStyle.menu.launcherIconSize
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
                                        color: Core.Colors.textColor
                                        font.family: Core.Colors.fontFamily
                                        font.pixelSize: Core.MenuStyle.menu.launcherFontSize
                                        font.weight: Core.Colors.bodyWeight
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                            onEntered: {
                                if (index >= 0 && index < laRoot.apps.length) laRoot.selIndex = index;
                            }
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
                    property int selIndex: -1
                    focus: true
                    Component.onCompleted: forceActiveFocus()
                    function clampSelection() {
                        selIndex = items.length > 0 ? Math.max(0, Math.min(items.length - 1, selIndex)) : -1;
                    }

                    function moveSelection(delta) {
                        clampSelection();
                        if (items.length === 0) return;
                        selIndex = Math.max(0, Math.min(items.length - 1, selIndex + delta));
                        chList.positionViewAtIndex(selIndex, ListView.Contain);
                    }

                    function handleKey(key) {
                        if (key === Qt.Key_Up) moveSelection(-1);
                        else if (key === Qt.Key_Down) moveSelection(1);
                        else if (key === Qt.Key_Home) {
                            selIndex = items.length > 0 ? 0 : -1;
                            if (selIndex >= 0) chList.positionViewAtIndex(selIndex, ListView.Beginning);
                        } else if (key === Qt.Key_End) {
                            selIndex = items.length - 1;
                            if (selIndex >= 0) chList.positionViewAtIndex(selIndex, ListView.End);
                        } else return false;
                        return true;
                    }

                    onItemsChanged: clampSelection()
                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Up) {
                            moveSelection(-1);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Down) {
                            moveSelection(1);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Left || event.key === Qt.Key_Right) {
                            // Clipboard entries are currently a one-column list.
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Home) {
                            selIndex = items.length > 0 ? 0 : -1;
                            if (selIndex >= 0) chList.positionViewAtIndex(selIndex, ListView.Beginning);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_End) {
                            selIndex = items.length - 1;
                            if (selIndex >= 0) chList.positionViewAtIndex(selIndex, ListView.End);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (selIndex >= 0 && selIndex < items.length) {
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
                        spacing: Core.MenuStyle.menu.launcherSpacing

                        Text {
                            text: "Clipboard"
                            color: Core.Colors.textColor
                            font.family: Core.Colors.fontFamily
                            font.pixelSize: Core.MenuStyle.menu.clipboardHeadingFontSize
                            font.weight: Core.Colors.bodyWeight
                        }

                        ListView {
                            id: chList
                            width: parent.width
                            height: parent.height - Core.MenuStyle.bar.loaderPadding * 2
                            clip: true
                            spacing: Core.MenuStyle.menu.clipboardSpacing
                            model: chRoot.items
                            currentIndex: chRoot.selIndex
                            onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                            delegate: Rectangle {
                                width: chList.width
                                height: Core.MenuStyle.menu.clipboardItemHeight
                                radius: height / 2
                                color: chMouse.containsMouse || index === chRoot.selIndex
                                       ? Core.Colors.fillActive
                                       : Core.MenuStyle.subtleSurfaceColor
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    x: Core.MenuStyle.sharedSpacing.paddingLarge
                                    width: parent.width - Core.MenuStyle.sharedSpacing.paddingLarge * 2
                                    elide: Text.ElideRight
                                    text: modelData.split("\t").slice(1).join(" ")
                                    color: Core.Colors.textColor
                                    font.family: Core.Colors.fontFamily
                                    font.pixelSize: Core.MenuStyle.menu.clipboardFontSize
                                    font.weight: Core.Colors.bodyWeight
                                }

                                MouseArea {
                                    id: chMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                            onEntered: {
                                if (index >= 0 && index < chRoot.items.length) chRoot.selIndex = index;
                            }
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
                Item {
                    id: wpRoot
                    anchors.fill: parent
                    focus: true

                    property var items: []
                    property int currentCenterIndex: -1
                    property real visualCenterIndex: currentCenterIndex
                    property string activeWallpaperPath: ""

                    Component.onCompleted: {
                        forceActiveFocus();
                        currentWallpaperReader.running = true;
                    }

                    function clampCenter() {
                        currentCenterIndex = items.length > 0
                            ? Math.max(0, Math.min(items.length - 1, currentCenterIndex))
                            : -1;
                    }

                    function initializeCenter() {
                        if (items.length === 0) {
                            currentCenterIndex = -1;
                            return;
                        }
                        const found = items.findIndex(item => item.path === activeWallpaperPath);
                        currentCenterIndex = found >= 0 ? found : 0;
                    }

                    function handleKey(key) {
                        if (key === Qt.Key_Left) moveCenter(-1);
                        else if (key === Qt.Key_Right) moveCenter(1);
                        else if (key === Qt.Key_Home) {
                            currentCenterIndex = items.length > 0 ? 0 : -1;
                        } else if (key === Qt.Key_End) {
                            currentCenterIndex = items.length - 1;
                        } else return false;
                        return true;
                    }

                    function moveCenter(delta) {
                        if (items.length === 0) {
                            currentCenterIndex = -1;
                            return;
                        }
                        currentCenterIndex = Math.max(0, Math.min(items.length - 1,
                            currentCenterIndex + delta));
                    }

                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Right || event.key === Qt.Key_L) {
                            moveCenter(1);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Left || event.key === Qt.Key_H) {
                            moveCenter(-1);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Up || event.key === Qt.Key_Down) {
                            // The coverflow is a single horizontal row.
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Home) {
                            currentCenterIndex = items.length > 0 ? 0 : -1;
                            event.accepted = true;
                        } else if (event.key === Qt.Key_End) {
                            currentCenterIndex = items.length - 1;
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (currentCenterIndex >= 0 && currentCenterIndex < items.length)
                                wpRoot.applyWallpaper(items[currentCenterIndex].path);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Escape) {
                            Core.AppState.closeMorph();
                            event.accepted = true;
                        }
                    }

                    onCurrentCenterIndexChanged: {
                        clampCenter();
                        visualCenterIndex = currentCenterIndex;
                    }
                    onItemsChanged: initializeCenter()

                    Behavior on visualCenterIndex {
                        NumberAnimation {
                            duration: Core.MenuStyle.menuTransition.popupDuration
                            easing.type: Core.MenuStyle.bezierSplineType
                            easing.bezierCurve: Core.MenuStyle.sharedAnimation.defaultSpatialCurve
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
                                wpRoot.initializeCenter();
                            }
                        }
                    }

                    Process {
                        id: currentWallpaperReader
                        command: ["cat", Quickshell.env("HOME") + "/.cache/yahpax/rice/current-wallpaper"]
                        running: false
                        stdout: StdioCollector {
                            onStreamFinished: {
                                wpRoot.activeWallpaperPath = this.text.split("\n")[0].trim();
                                wpRoot.initializeCenter();
                            }
                        }
                    }

                    RowLayout {
                        id: wallpaperHeader
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        width: parent.width
                        height: Core.MenuStyle.menu.wallpaperHeaderHeight
                        spacing: Core.MenuStyle.sharedSpacing.small

                        Text {
                            Layout.fillWidth: true
                            text: "Wallpapers"
                            color: Core.Colors.textColor
                            font.family: Core.Colors.fontFamily
                            font.pixelSize: Core.MenuStyle.menu.wallpaperTitleFontSize
                            font.weight: Core.Colors.titleWeight
                        }

                        Text {
                            text: wpRoot.items.length > 0
                                ? (wpRoot.currentCenterIndex + 1) + " / " + wpRoot.items.length
                                : "empty"
                            color: Core.Colors.mutedText
                            font.family: Core.Colors.fontFamily
                            font.pixelSize: Core.MenuStyle.menu.wallpaperCounterFontSize
                            font.weight: Core.Colors.labelWeight
                        }
                    }

                    Item {
                        id: coverflow
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: wallpaperHeader.bottom
                        anchors.topMargin: Core.MenuStyle.menu.wallpaperContentGap
                        anchors.bottom: parent.bottom
                        clip: true

                        Text {
                            anchors.centerIn: parent
                            visible: wpRoot.items.length === 0
                            text: "No wallpapers found"
                            color: Core.Colors.mutedText
                            font.family: Core.Colors.fontFamily
                            font.pixelSize: Core.MenuStyle.menu.wallpaperEmptyFontSize
                        }

                        Repeater {
                            model: [-3, -2, -1, 0, 1, 2, 3]

                            delegate: Item {
                                id: slot
                                required property int modelData
                                property int offset: modelData
                                property real visualOffset: offset + (wpRoot.currentCenterIndex - wpRoot.visualCenterIndex)
                                property int wallpaperIndex: Math.round(wpRoot.visualCenterIndex + offset)
                                property bool valid: wallpaperIndex >= 0 && wallpaperIndex < wpRoot.items.length
                                property var wallpaper: valid ? wpRoot.items[wallpaperIndex] : null
                                property int tier: Math.min(3, Math.abs(Math.round(visualOffset)))
                                property real thumbWidth: tier === 0 ? Core.MenuStyle.menu.wallpaperCenterWidth
                                    : tier === 1 ? Core.MenuStyle.menu.wallpaperNearWidth
                                    : tier === 2 ? Core.MenuStyle.menu.wallpaperMiddleWidth
                                    : Core.MenuStyle.menu.wallpaperFarWidth
                                property real thumbHeight: tier === 0 ? Core.MenuStyle.menu.wallpaperCenterHeight
                                    : tier === 1 ? Core.MenuStyle.menu.wallpaperNearHeight
                                    : tier === 2 ? Core.MenuStyle.menu.wallpaperMiddleHeight
                                    : Core.MenuStyle.menu.wallpaperFarHeight
                                property real centerX: (coverflow.width - Core.MenuStyle.menu.wallpaperCenterWidth) / 2
                                // Use the coverflow's actual center point. The
                                // overlap is increased only when necessary so
                                // all three side tiers remain inside a narrow
                                // panel without changing their size tiers.
                                property real effectiveOverlap: Math.max(
                                    Core.MenuStyle.menu.wallpaperTierOverlap,
                                    (Core.MenuStyle.menu.wallpaperCenterWidth / 2
                                     + Core.MenuStyle.menu.wallpaperFarWidth
                                     + 2 * Core.MenuStyle.menu.wallpaperNearWidth
                                     - coverflow.width / 2) / 3)
                                property real itemX: {
                                    const direction = visualOffset < 0 ? -1 : 1;
                                    const distance = Math.abs(visualOffset);
                                    const centerPoint = coverflow.width / 2;
                                    if (distance < 0.01) return centerX;
                                    let x = centerPoint + direction * (Core.MenuStyle.menu.wallpaperCenterWidth / 2
                                        + thumbWidth / 2 - effectiveOverlap);
                                    if (distance > 1) x += direction * (distance - 1)
                                        * (Core.MenuStyle.menu.wallpaperNearWidth - effectiveOverlap);
                                    return x - thumbWidth / 2;
                                }
                                x: itemX
                                y: (coverflow.height - thumbHeight) / 2 + (tier === 0 ? 0 : Core.MenuStyle.menu.wallpaperSideLift)
                                width: thumbWidth
                                height: thumbHeight
                                z: 10 - tier
                                opacity: valid ? 1 : 0
                                visible: valid

                                Behavior on x { NumberAnimation { duration: Core.MenuStyle.menuTransition.popupDuration; easing.type: Core.MenuStyle.bezierSplineType; easing.bezierCurve: Core.MenuStyle.sharedAnimation.defaultSpatialCurve } }
                                Behavior on y { NumberAnimation { duration: Core.MenuStyle.menuTransition.popupDuration; easing.type: Core.MenuStyle.bezierSplineType; easing.bezierCurve: Core.MenuStyle.sharedAnimation.defaultSpatialCurve } }
                                Behavior on width { NumberAnimation { duration: Core.MenuStyle.menuTransition.popupDuration; easing.type: Core.MenuStyle.bezierSplineType; easing.bezierCurve: Core.MenuStyle.sharedAnimation.defaultSpatialCurve } }
                                Behavior on height { NumberAnimation { duration: Core.MenuStyle.menuTransition.popupDuration; easing.type: Core.MenuStyle.bezierSplineType; easing.bezierCurve: Core.MenuStyle.sharedAnimation.defaultSpatialCurve } }
                                Behavior on opacity { NumberAnimation { duration: Core.MenuStyle.menuTransition.popupDuration; easing.type: Core.MenuStyle.bezierSplineType; easing.bezierCurve: Core.MenuStyle.sharedAnimation.defaultSpatialCurve } }

                                Core.SharpShape {
                                    anchors.fill: parent
                                    cutBottomLeft: true
                                    cutBottomRight: true
                                    cutAmount: Core.MenuStyle.radius
                                    fillColor: Core.MenuStyle.dockButtonRule.idleSurface
                                    strokeColor: tier === 0 ? Core.Colors.borderColor : Core.Colors.borderColor
                                    strokeWidth: Core.MenuStyle.sharedRadius.border

                                    Image {
                                        anchors.fill: parent
                                        anchors.margins: Core.MenuStyle.sharedRadius.border
                                        source: slot.wallpaper ? slot.wallpaper.thumb : ""
                                        fillMode: Image.PreserveAspectCrop
                                        asynchronous: true
                                        cache: true
                                        sourceSize.width: Core.MenuStyle.menu.wallpaperSourceWidth
                                        sourceSize.height: Core.MenuStyle.menu.wallpaperSourceHeight
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            if (!slot.valid) return;
                                            if (slot.offset === 0) wpRoot.applyWallpaper(slot.wallpaper.path);
                                            else wpRoot.currentCenterIndex = slot.wallpaperIndex;
                                        }
                                    }
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
                        spacing: Core.MenuStyle.menu.placeholderSpacing
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "\uf013"
                        font.family: Core.Colors.iconFontFamily
                            font.pixelSize: Core.MenuStyle.menu.placeholderIconFontSize
                            color: Core.Colors.mutedText
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "under construction"
                            font.family: Core.Colors.fontFamily
                            font.pixelSize: Core.MenuStyle.menu.placeholderTextFontSize
                        font.weight: Core.Colors.bodyWeight
                            color: Core.Colors.mutedText
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

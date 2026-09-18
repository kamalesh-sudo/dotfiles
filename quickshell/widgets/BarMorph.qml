import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../core" as Core
import ".." as Local

// The "lock" action in the power menu assumes hyprlock is installed —
// swap the command string in powerContent if you use something else.

Item {
    id: root

    property var modelData
    property real normalWidth: 576
    property real normalHeight: Core.Colors.barHeight + 3
    property var enabledModes: ["launcher", "clipboard", "power", "notifications", "wifi", "wallpaper"]
    readonly property bool onThisScreen: Core.AppState.morphScreenName === (modelData ? modelData.name : "")
    readonly property bool expanded: enabledModes.indexOf(Core.AppState.barMorph) >= 0
                                      && Core.AppState.barMorph !== "" && onThisScreen
    readonly property var expandedSize: root.targetSize(Core.AppState.barMorph, modelData ? modelData.width : 1920)
    readonly property real expandedWidth: expandedSize.w
    readonly property real expandedHeight: expandedSize.h + normalHeight

    width: expanded ? expandedWidth : normalWidth
    height: expanded ? expandedHeight : normalHeight

    Behavior on width {
        NumberAnimation { duration: 320; easing.type: Easing.OutQuint }
    }
    Behavior on height {
        NumberAnimation { duration: 320; easing.type: Easing.OutQuint }
    }

    // Desktop entries are stable for the lifetime of the shell. Keep the
    // sorted base list on the persistent BarMorph instead of rebuilding it
    // every time the launcher Loader is created.
    readonly property var launcherApplications: {
        const all = [...DesktopEntries.applications.values].filter(d => d.name);
        all.sort((a, b) => a.name.localeCompare(b.name));
        return all;
    }

    function notificationSize() {
        const count = Math.min(3, Math.max(1, Core.AppState.notifications.length));
        return { w: 480, h: 72 + count * 58 };
    }

    function targetSize(name, screenWidth) {
        switch (name) {
            case "power":       return { w: 300, h: 100 };
            case "wallpaper":   return { w: Math.min(screenWidth * 0.5, 720), h: 118 };
            case "launcher":    return { w: 900, h: 380 };
            case "clipboard":   return { w: 560, h: 380 };
            case "wifi":        return root.notificationSize();
            case "notifications": return root.notificationSize();
            default:            return { w: 280, h: 90 };
        }
    }

    Rectangle {
        id: panel
        anchors.fill: parent
        radius: root.expanded ? Math.min(height / 2, 20) : 0
        clip: true
        color: root.expanded ? Core.MenuStyle.morphPanelColor : "transparent"
        border.color: Core.Colors.accent
        border.width: root.expanded ? Core.MenuStyle.borderWidth : 0

        MouseArea {
            anchors { left: parent.left; right: parent.right; top: barContent.bottom; bottom: parent.bottom }
            enabled: root.expanded
            onClicked: Core.AppState.closeMorph()
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

            readonly property real screenWidth: modelData ? modelData.width : 1920
            readonly property real screenHeight: modelData ? modelData.height : 1080

            function triggerMorph(name) {
                const screenName = modelData ? modelData.name : "";
                if (Core.AppState.barMorph === name && Core.AppState.morphScreenName === screenName) {
                    Core.AppState.closeMorph();
                    return;
                }
                morphTriggered(name);
            }

            Rectangle {
                id: barBg
                anchors.fill: parent
                anchors.topMargin: 2
                anchors.bottomMargin: 1
                opacity: Core.AppState.barTemporarilyHidden ? 0 : 1
                Behavior on opacity { NumberAnimation { duration: 420; easing.type: Easing.InOutQuad } }
                radius: height / 2
                color: Qt.rgba(Local.Colors.background.r, Local.Colors.background.g,
                               Local.Colors.background.b, 0.14)
                border.color: Local.Colors.accent
                border.width: 1

                RowLayout {
                    id: barRow
                    anchors.fill: parent
                    anchors.leftMargin: 18
                    anchors.rightMargin: 18
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
                            property real blobWidth: cellWidth
                            onActiveIndexChanged: {
                                const from = previousIndex;
                                const to = activeIndex;
                                previousIndex = to;
                                blobTransition.spanX = Math.min(from * unit, to * unit);
                                blobTransition.spanWidth = Math.abs(to * unit - from * unit) + cellWidth;
                                blobTransition.settleX = to * unit;
                                blobTransition.stop();
                                blobTransition.start();
                            }
                            SequentialAnimation {
                                id: blobTransition
                                property real spanX: 0
                                property real spanWidth: workspaces.cellWidth
                                property real settleX: 0
                                ParallelAnimation {
                                    NumberAnimation { target: workspaces; property: "blobX"; to: blobTransition.spanX; duration: 140; easing.type: Easing.OutQuad }
                                    NumberAnimation { target: workspaces; property: "blobWidth"; to: blobTransition.spanWidth; duration: 140; easing.type: Easing.OutQuad }
                                }
                                ParallelAnimation {
                                    NumberAnimation { target: workspaces; property: "blobX"; to: blobTransition.settleX; duration: 180; easing.type: Easing.InOutQuad }
                                    NumberAnimation { target: workspaces; property: "blobWidth"; to: workspaces.cellWidth; duration: 180; easing.type: Easing.InOutQuad }
                                }
                            }
                            Rectangle { x: workspaces.blobX; width: workspaces.blobWidth; height: Local.Colors.barHeight - 17; radius: height / 2; color: Qt.rgba(1, 1, 1, 0.92) }
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
                                        Text { anchors.centerIn: parent; text: workspaceNumber; font.family: Local.Colors.fontFamily; font.pixelSize: 12; font.weight: isActive ? Font.Bold : Local.Colors.textWeight; color: isActive ? "#101018" : Local.Colors.foreground; opacity: isActive ? 1.0 : (isOccupied ? 0.85 : 0.35) }
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
                            font.weight: Local.Colors.textWeight
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
                            spacing: 4
                            Repeater {
                                model: [
                                    { glyph: "\uf1eb", morph: "wifi" },
                                    { glyph: "\uf0f3", morph: "notifications" },
                                    { glyph: "\uf011", morph: "power" }
                                ]
                                Rectangle {
                                    width: 30
                                    height: Local.Colors.barHeight - 10
                                    radius: height / 2
                                    color: (Core.AppState.barMorph === modelData.morph && Core.AppState.morphScreenName === (barContent.modelData ? barContent.modelData.name : ""))
                                           ? Qt.rgba(1, 1, 1, 0.20)
                                           : hoverArea.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : "transparent"
                                    Behavior on color { ColorAnimation { duration: 120 } }
                                    Text { anchors.centerIn: parent; text: modelData.glyph; font.family: "Symbols Nerd Font"; font.pixelSize: 13; color: Local.Colors.foreground }
                                    MouseArea { id: hoverArea; anchors.fill: parent; hoverEnabled: true; onClicked: barContent.triggerMorph(modelData.morph) }
                                }
                            }
                        }
                    }
                    property real sideWidth: 220
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
                    case "power": return powerContent;
                    case "wallpaper": return wallpaperContent;
                    case "launcher": return launcherContent;
                    case "clipboard": return clipboardContent;
                    case "notifications": return notificationContent;
                    case "wifi": return wifiContent;
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
                                    font.weight: Core.Colors.textWeight
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
                                       ? Qt.rgba(Core.Colors.accent.r, Core.Colors.accent.g,
                                                 Core.Colors.accent.b, 0.30)
                                       : "transparent"
                                Behavior on color { ColorAnimation { duration: 100 } }

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
                                        font.weight: Core.Colors.textWeight
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
                                    Quickshell.env("HOME") + "/.config/quickshell/scripts/cliphist-restore.fish",
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
                            font.weight: Core.Colors.textWeight
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
                                       ? Qt.rgba(Core.Colors.accent.r, Core.Colors.accent.g,
                                                 Core.Colors.accent.b, 0.25)
                                       : Core.MenuStyle.subtleSurfaceColor
                                Behavior on color { ColorAnimation { duration: 100 } }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    x: 14
                                    width: parent.width - 28
                                    elide: Text.ElideRight
                                    text: modelData.split("\t").slice(1).join(" ")
                                    color: Core.Colors.foreground
                                    font.family: Core.Colors.fontFamily
                                    font.pixelSize: 11
                                    font.weight: Core.Colors.textWeight
                                }

                                MouseArea {
                                    id: chMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: chRoot.selIndex = index
                                    onClicked: {
                                        Quickshell.execDetached(["fish",
                                            Quickshell.env("HOME") + "/.config/quickshell/scripts/cliphist-restore.fish",
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
                id: powerContent
                RowLayout {
                    id: powerRoot
                    anchors.fill: parent
                    spacing: 8
                    property var powerOptions: [
                        { glyph: "\uf023", label: "Lock",     action: "lock" },
                        { glyph: "\uf186", label: "Sleep",    action: "sleep" },
                        { glyph: "\uf2f1", label: "Reboot",   action: "reboot" },
                        { glyph: "\uf011", label: "Shutdown", action: "shutdown" }
                    ]
                    property int selIndex: 0
                    focus: true
                    Component.onCompleted: forceActiveFocus()

                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Up) {
                            selIndex = Math.max(0, selIndex - 1)
                            event.accepted = true
                        } else if (event.key === Qt.Key_Down) {
                            selIndex = Math.min(powerOptions.length - 1, selIndex + 1)
                            event.accepted = true
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            Core.AppState.runPowerAction(powerOptions[selIndex].action)
                            event.accepted = true
                        } else if (event.key === Qt.Key_Escape) {
                            Core.AppState.closeMorph()
                            event.accepted = true
                        }
                    }

                    Repeater {
                        model: powerRoot.powerOptions

                        delegate: Rectangle {
                            id: powerBtn
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: Core.MenuStyle.cardRadius
                            color: hoverArea.containsMouse || index === powerRoot.selIndex
                                   ? Qt.rgba(Core.Colors.accent.r, Core.Colors.accent.g,
                                             Core.Colors.accent.b, 0.25)
                                   : Core.MenuStyle.subtleSurfaceColor
                            border.width: 0

                            Behavior on color { ColorAnimation { duration: 120 } }

                            Column {
                                anchors.centerIn: parent
                                spacing: 4
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.glyph
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 18
                                    color: Core.Colors.foreground
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.label
                                    font.family: Core.Colors.fontFamily
                                    font.pixelSize: 10
                                    font.weight: Core.Colors.textWeight
                                    color: Core.Colors.muted
                                }
                            }

                            MouseArea {
                                id: hoverArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: powerRoot.selIndex = index
                                onClicked: Core.AppState.runPowerAction(modelData.action)
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
                    spacing: 8
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
                            Quickshell.env("HOME") + "/.config/quickshell/scripts/apply-wallpaper.fish",
                            path, "grow", posX + "," + posY]);
                    }

                    Process {
                        id: wpLister
                        command: ["fish",
                            Quickshell.env("HOME") + "/.config/quickshell/scripts/wallpaper-list-thumbnails.fish"]
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
                        font.weight: Core.Colors.textWeight
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
                id: notificationContent

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8
                    focus: true

                    Keys.onPressed: (event) => {
                        Core.AppState.closeMorph()
                        event.accepted = true
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "NOTIFICATIONS"
                            color: Core.Colors.foreground
                            font.family: Core.Colors.fontFamily
                            font.pixelSize: 12
                            font.weight: Core.Colors.textWeight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "CLEAR ALL"
                            color: Core.Colors.accent
                            font.family: Core.Colors.fontFamily
                            font.pixelSize: 10
                            font.weight: Core.Colors.textWeight

                            MouseArea {
                                anchors.fill: parent
                                onClicked: Core.AppState.clearNotifications()
                            }
                        }
                    }

                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 4
                        model: Core.AppState.notifications

                        delegate: Rectangle {
                            required property var modelData
                            readonly property int notificationId: modelData.id
                            width: ListView.view.width
                            height: 78
                            radius: Core.MenuStyle.cardRadius
                            color: Core.MenuStyle.notificationSurfaceColor
                            border.width: Core.MenuStyle.borderWidth
                            border.color: Core.Colors.muted

                            Column {
                                anchors.left: parent.left
                                anchors.right: dismiss.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                anchors.leftMargin: 10
                                anchors.topMargin: 8
                                anchors.bottomMargin: 8
                                spacing: 2

                                Text {
                                    text: modelData.summary
                                    color: Core.Colors.foreground
                                    font.family: Core.Colors.fontFamily
                                    font.pixelSize: 11
                                    font.weight: Core.Colors.textWeight
                                    elide: Text.ElideRight
                                    width: parent.width
                                }

                                Text {
                                    text: modelData.body
                                    color: Core.Colors.muted
                                    font.family: Core.Colors.fontFamily
                                    font.pixelSize: 10
                                    font.weight: Core.Colors.textWeight
                                    elide: Text.ElideRight
                                    width: parent.width
                                }

                                Row {
                                    spacing: 6

                                    Repeater {
                                        model: modelData.actions || []

                                        delegate: Rectangle {
                                            width: actionLabel.implicitWidth + 16
                                            height: 20
                                            radius: 10
                                            color: Core.MenuStyle.inputSurfaceColor
                                            border.color: Core.Colors.accent
                                            border.width: Core.MenuStyle.borderWidth

                                            Text {
                                                id: actionLabel
                                                anchors.centerIn: parent
                                                text: modelData.text
                                                color: Core.Colors.foreground
                                                font.family: Core.Colors.fontFamily
                                                font.pixelSize: 9
                                                font.weight: Core.Colors.textWeight
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: Core.AppState.invokeNotificationAction(notificationId, modelData.identifier)
                                            }
                                        }
                                    }
                                }
                            }

                            Text {
                                id: dismiss
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.rightMargin: 10
                                text: "×"
                                color: Core.Colors.accent
                                font.pixelSize: 18

                                MouseArea {
                                    anchors.fill: parent
                                onClicked: Core.AppState.dismissNotification(modelData.id)
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: Core.AppState.notifications.length === 0
                            text: "NO NOTIFICATIONS"
                            color: Core.Colors.muted
                            font.family: Core.Colors.fontFamily
                            font.pixelSize: 10
                            font.weight: Core.Colors.textWeight
                        }
                    }
                }
            }
// 
            Component {
                id: wifiContent

                Item {
                    id: wifiRoot
                    anchors.fill: parent
                    focus: true
                    property var connected: null
                    property var networks: []
                    property var saved: []
                    property string view: "default"
                    property string promptSsid: ""
                    property string promptError: ""

                    function secure(security) {
                        const value = String(security || "").trim().toLowerCase();
                        return value.length > 0 && value !== "--" && value !== "open";
                    }
                    function parseWifi(text) {
                        const rows = [];
                        for (const line of text.split("\n")) {
                            const fields = line.split(":");
                            if (fields.length < 4 || fields[1].trim().length === 0) continue;
                            rows.push({ inUse: fields[0].trim(), ssid: fields[1], security: fields[2], signal: Number(fields[3]) || 0 });
                        }
                        connected = rows.find(item => item.inUse === "*") || null;
                        networks = rows.filter(item => item.inUse !== "*");
                    }
                    function parseSaved(text) {
                        const rows = [];
                        for (const line of text.split("\n")) {
                            const fields = line.split(":");
                            if (fields.length >= 3 && fields[1] === "802-11-wireless") rows.push({ ssid: fields[0], security: "saved", signal: 0 });
                        }
                        saved = rows;
                    }
                    function scan() { wifiScan.running = true; wifiSaved.running = true; }
                    function refresh() { wifiRescan.running = true; wifiSaved.running = true; }
                    function choose(network) {
                        if (!network) return;
                        if (network.inUse === "*") view = "connected";
                        else if (secure(network.security)) {
                            promptSsid = network.ssid; promptError = ""; view = "prompt"; passwordInput.forceActiveFocus();
                        } else connect(network.ssid, "");
                    }
                    function connect(ssid, password) {
                        wifiConnect.command = password.length > 0
                            ? ["nmcli", "device", "wifi", "connect", ssid, "password", password]
                            : ["nmcli", "device", "wifi", "connect", ssid];
                        wifiConnect.running = true;
                    }

                    Component.onCompleted: scan()
                    Keys.onEscapePressed: {
                        if (view === "default") Core.AppState.closeMorph();
                        else view = "default";
                        event.accepted = true;
                    }

                    Process {
                        id: wifiScan
                        command: ["nmcli", "-t", "-e", "no", "-f", "IN-USE,SSID,SECURITY,SIGNAL", "device", "wifi", "list"]
                        stdout: StdioCollector { onStreamFinished: wifiRoot.parseWifi(this.text) }
                    }
                    Process {
                        id: wifiRescan
                        command: ["nmcli", "device", "wifi", "rescan"]
                        onExited: wifiScan.running = true
                    }
                    Process {
                        id: wifiSaved
                        command: ["nmcli", "-t", "-e", "no", "-f", "NAME,TYPE,DEVICE", "connection", "show"]
                        stdout: StdioCollector { onStreamFinished: wifiRoot.parseSaved(this.text) }
                    }
                    Process {
                        id: wifiConnect
                        onExited: (exitCode, exitStatus) => {
                            if (exitCode === 0) Core.AppState.closeMorph();
                            else { wifiRoot.promptError = "Connection failed"; wifiFailure.restart(); }
                        }
                    }
                    Process {
                        id: wifiDisconnect
                        command: wifiRoot.connected ? ["nmcli", "connection", "down", "id", wifiRoot.connected.ssid] : []
                        onExited: Core.AppState.closeMorph()
                    }
                    Timer { id: wifiFailure; interval: 1100; onTriggered: Core.AppState.closeMorph() }

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 6
                        visible: wifiRoot.view !== "prompt" && wifiRoot.view !== "connected"
                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: wifiRoot.view === "default" ? "WIFI" : wifiRoot.view.toUpperCase()
                                color: Core.Colors.foreground
                                font.family: Core.Colors.fontFamily
                                font.weight: Core.Colors.textWeight
                                Layout.fillWidth: true
                            }
                            Text {
                                text: wifiRoot.view === "default" ? "" : "BACK"
                                color: Core.Colors.accent
                                font.family: Core.Colors.fontFamily
                                font.pixelSize: 10
                                font.weight: Core.Colors.textWeight
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: wifiRoot.view = "default"
                                }
                            }
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Core.Colors.accent
                            opacity: 0.35
                        }
                        Rectangle {
                            visible: wifiRoot.view === "default" && wifiRoot.connected !== null
                            Layout.fillWidth: true
                            height: 38
                            radius: Core.MenuStyle.cardRadius
                            color: Core.MenuStyle.accentSurfaceColor
                            border.width: Core.MenuStyle.borderWidth
                            border.color: Core.Colors.accent
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 9
                                Text {
                                    text: wifiRoot.connected ? "●  " + wifiRoot.connected.ssid : ""
                                    color: Core.Colors.foreground
                                    font.family: Core.Colors.fontFamily
                                    font.pixelSize: 10
                                    font.weight: Core.Colors.textWeight
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: "DETAILS"
                                    color: Core.Colors.muted
                                    font.family: Core.Colors.fontFamily
                                    font.pixelSize: 9
                                    font.weight: Core.Colors.textWeight
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: wifiRoot.view = "connected"
                                    }
                                }
                            }
                        }
                        Rectangle {
                            visible: wifiRoot.view === "default"
                            Layout.fillWidth: true
                            height: 1
                            color: Core.Colors.accent
                            opacity: 0.25
                        }
                        ListView {
                            id: wifiList
                            visible: wifiRoot.view !== "default" || wifiRoot.connected === null
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            spacing: 4
                            model: wifiRoot.view === "default" ? wifiRoot.networks.slice(0, 4) : (wifiRoot.view === "all" ? wifiRoot.networks : wifiRoot.saved)
                            delegate: Rectangle {
                                width: wifiList.width
                                height: 32
                                radius: Core.MenuStyle.cardRadius
                                color: wifiRow.containsMouse ? Core.MenuStyle.hoverSurfaceColor : Core.MenuStyle.subtleSurfaceColor
                                border.width: Core.MenuStyle.borderWidth
                                border.color: Core.Colors.muted
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    Text {
                                        text: modelData.ssid
                                        color: Core.Colors.foreground
                                        font.family: Core.Colors.fontFamily
                                        font.pixelSize: 10
                                        font.weight: Core.Colors.textWeight
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                    Text {
                                        visible: modelData.signal > 0
                                        text: modelData.signal + "%"
                                        color: Core.Colors.muted
                                        font.family: Core.Colors.fontFamily
                                        font.pixelSize: 9
                                        font.weight: Core.Colors.textWeight
                                    }
                                }
                                MouseArea {
                                    id: wifiRow
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: wifiRoot.choose(modelData)
                                }
                            }
                        }
                        Row {
                            visible: wifiRoot.view === "default"
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 4
                            Repeater {
                                model: [
                                    { label: "↻", action: "refresh" },
                                    { label: "ALL", action: "all" },
                                    { label: "SAVED", action: "saved" }
                                ]
                                delegate: Rectangle {
                                    width: modelData.action === "refresh" ? 32 : 60
                                    height: 26
                                    radius: Core.MenuStyle.cardRadius
                                    color: wifiAction.containsMouse ? Core.MenuStyle.hoverSurfaceColor : "transparent"
                                    border.width: Core.MenuStyle.borderWidth
                                    border.color: Core.Colors.accent
                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.label
                                        color: Core.Colors.accent
                                        font.family: Core.Colors.fontFamily
                                        font.pixelSize: 9
                                        font.weight: Core.Colors.textWeight
                                    }
                                    MouseArea {
                                        id: wifiAction
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: {
                                            if (modelData.action === "refresh") wifiRoot.refresh()
                                            else wifiRoot.view = modelData.action
                                        }
                                    }
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 8
                        visible: wifiRoot.view === "prompt" || wifiRoot.view === "connected"
                        Text {
                            text: wifiRoot.view === "connected" ? wifiRoot.connected.ssid : "CONNECT TO " + wifiRoot.promptSsid
                            color: Core.Colors.foreground
                            font.family: Core.Colors.fontFamily
                            font.pixelSize: 12
                            font.weight: Core.Colors.textWeight
                        }
                        Text {
                            visible: wifiRoot.view === "connected"
                            text: wifiRoot.connected ? "Connected\nSignal: " + wifiRoot.connected.signal + "%" : ""
                            color: Core.Colors.muted
                            font.family: Core.Colors.fontFamily
                            font.pixelSize: 10
                            font.weight: Core.Colors.textWeight
                        }
                        TextInput {
                            id: passwordInput
                            visible: wifiRoot.view === "prompt"
                            Layout.fillWidth: true
                            height: 32
                            echoMode: TextInput.Password
                            color: Core.Colors.foreground
                            font.family: Core.Colors.fontFamily
                            font.pixelSize: 11
                            font.weight: Core.Colors.textWeight
                            onAccepted: wifiRoot.connect(wifiRoot.promptSsid, text)
                            Rectangle {
                                anchors.fill: parent
                                z: -1
                                radius: Core.MenuStyle.cardRadius
                                color: Core.MenuStyle.notificationSurfaceColor
                                border.width: Core.MenuStyle.borderWidth
                                border.color: Core.Colors.accent
                            }
                        }
                        Text {
                            visible: wifiRoot.promptError.length > 0
                            text: wifiRoot.promptError
                            color: Core.Colors.accent
                            font.family: Core.Colors.fontFamily
                            font.pixelSize: 10
                            font.weight: Core.Colors.textWeight
                        }
                        Row {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 4
                            Rectangle {
                                width: 78
                                height: 28
                                radius: Core.MenuStyle.cardRadius
                                color: wifiPrompt.containsMouse ? Core.MenuStyle.hoverSurfaceColor : "transparent"
                                border.width: Core.MenuStyle.borderWidth
                                border.color: Core.Colors.accent
                                Text {
                                    anchors.centerIn: parent
                                    text: wifiRoot.view === "connected" ? "DISCONNECT" : "CONNECT"
                                    color: Core.Colors.accent
                                    font.family: Core.Colors.fontFamily
                                    font.pixelSize: 9
                                    font.weight: Core.Colors.textWeight
                                }
                                MouseArea {
                                    id: wifiPrompt
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        if (wifiRoot.view === "connected") wifiDisconnect.running = true
                                        else wifiRoot.connect(wifiRoot.promptSsid, passwordInput.text)
                                    }
                                }
                            }
                            Rectangle {
                                width: 52
                                height: 28
                                radius: Core.MenuStyle.cardRadius
                                color: wifiBack.containsMouse ? Core.MenuStyle.hoverSurfaceColor : "transparent"
                                border.width: Core.MenuStyle.borderWidth
                                border.color: Core.Colors.muted
                                Text {
                                    anchors.centerIn: parent
                                    text: "BACK"
                                    color: Core.Colors.muted
                                    font.family: Core.Colors.fontFamily
                                    font.pixelSize: 9
                                    font.weight: Core.Colors.textWeight
                                }
                                MouseArea {
                                    id: wifiBack
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: wifiRoot.view = "default"
                                }
                            }
                        }
                    }
                }
            }
// 
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
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 18
                            color: Core.Colors.muted
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "under construction"
                            font.family: Core.Colors.fontFamily
                            font.pixelSize: 11
                            font.weight: Core.Colors.textWeight
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
        const width = Math.min(880, (screen ? screen.width : 1920) * 0.300);
        Core.AppState.openMorph(name,
            ((screen ? screen.width : 1920) - width) / 2,
            0,
            width,
            root.normalHeight,
            screenName,
            screen ? screen.height : 1080);
    }
}

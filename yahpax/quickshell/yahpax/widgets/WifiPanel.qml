import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking
import "../core" as Core
import ".." as Local

Item {
    id: root

    property string view: "default"
    property var selectedNetwork: null
    property string password: ""
    property string errorText: ""
    readonly property var availableNetworks: Local.WifiService.networks.filter(network => !network.connected)

    function isSecure(network) {
        return network && network.security !== WifiSecurityType.Open;
    }

    function choose(network) {
        if (!network)
            return;
        if (network.connected) {
            selectedNetwork = network;
            view = "connected";
        } else if (isSecure(network) && !network.known) {
            selectedNetwork = network;
            password = "";
            errorText = "";
            view = "password";
            passwordInput.forceActiveFocus();
        } else {
            Local.WifiService.connectNetwork(network, "");
        }
    }

    function submitPassword() {
        if (!selectedNetwork || password.length === 0)
            return;
        Local.WifiService.connectNetwork(selectedNetwork, password);
    }

    Connections {
        target: Local.WifiService
        function onConnectionSucceeded() {
            root.view = "default";
            root.selectedNetwork = null;
            root.password = "";
        }
        function onConnectionFailed(ssid, reason) {
            if (root.selectedNetwork && root.selectedNetwork.name === ssid)
                root.errorText = reason || "Connection failed";
        }
    }

    Keys.onEscapePressed: {
        if (root.view === "default")
            Core.AppState.closeMorph();
        else
            root.view = "default";
        event.accepted = true;
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Core.MenuStyle.sharedSpacing.medium

        RowLayout {
            Layout.fillWidth: true
            Text {
                Layout.fillWidth: true
                text: root.view === "default" ? "WIFI" : root.view.toUpperCase()
                color: Core.Colors.foreground
                font.family: Core.Colors.fontFamily
                font.weight: Core.Colors.titleWeight
            }
            Text {
                visible: root.view !== "default"
                text: "BACK"
                color: Core.Colors.accent
                font.family: Core.Colors.fontFamily
                font.pixelSize: 10
                MouseArea { anchors.fill: parent; onClicked: root.view = "default" }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Core.Colors.accent
            opacity: 0.35
        }

        Rectangle {
            visible: root.view === "default" && Local.WifiService.connected !== null
            Layout.fillWidth: true
            height: 38
            radius: Core.MenuStyle.sharedRadius.card
            color: Core.MenuStyle.activeRule.surface
            border.width: Core.MenuStyle.sharedRadius.border
            border.color: Core.Colors.accent
            RowLayout {
                anchors.fill: parent
                anchors.margins: 9
                Text {
                    Layout.fillWidth: true
                    text: Local.WifiService.connected ? "●  " + Local.WifiService.connected.name : ""
                    color: Core.Colors.foreground
                    font.family: Core.Colors.fontFamily
                    font.pixelSize: 10
                    elide: Text.ElideRight
                }
                Text {
                    text: "DETAILS"
                    color: Core.Colors.muted
                    font.family: Core.Colors.fontFamily
                    font.pixelSize: 9
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.selectedNetwork = Local.WifiService.connected;
                            root.view = "connected";
                        }
                    }
                }
            }
        }

        ListView {
            id: networkList
            visible: root.view === "default" || root.view === "all" || root.view === "saved"
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: Core.MenuStyle.sharedSpacing.small
            model: {
                if (!Local.WifiService.enabled)
                    return [];
                if (root.view === "saved")
                    return Local.WifiService.saved;
                if (root.view === "default")
                    return root.availableNetworks.slice(0, 4);
                return root.availableNetworks;
            }
            delegate: Rectangle {
                required property var modelData
                width: networkList.width
                height: 34
                radius: Core.MenuStyle.sharedRadius.card
                color: networkMouse.containsMouse ? Core.MenuStyle.hoverRule.surface : Core.MenuStyle.inactiveRule.surface
                border.width: Core.MenuStyle.sharedRadius.border
                border.color: modelData.connected ? Core.Colors.accent : Core.Colors.muted
                Behavior on color {
                    ColorAnimation {
                        duration: Core.MenuStyle.hoverRule.duration
                        easing.type: Core.MenuStyle.bezierSplineType
                        easing.bezierCurve: Core.MenuStyle.sharedAnimation.fastEffectsCurve
                    }
                }
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    Text {
                        Layout.fillWidth: true
                        text: modelData.name
                        color: Core.Colors.foreground
                        font.family: Core.Colors.fontFamily
                        font.pixelSize: 10
                        elide: Text.ElideRight
                    }
                    Text {
                        text: modelData.connected ? "CONNECTED" : modelData.known ? "SAVED" : ""
                        color: modelData.connected ? Core.Colors.accent : Core.Colors.muted
                        font.family: Core.Colors.fontFamily
                        font.pixelSize: 9
                    }
                    Text {
                        text: WifiSecurityType.toString(modelData.security)
                        color: Core.Colors.muted
                        font.family: Core.Colors.fontFamily
                        font.pixelSize: 9
                    }
                }
                MouseArea {
                    id: networkMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.choose(modelData)
                }
            }
        }

        ColumnLayout {
            visible: root.view === "connected" || root.view === "password"
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Core.MenuStyle.sharedSpacing.medium
            Text {
                Layout.fillWidth: true
                text: root.view === "connected" ? (root.selectedNetwork ? root.selectedNetwork.name : "CONNECTED") : "CONNECT TO " + (root.selectedNetwork ? root.selectedNetwork.name : "NETWORK")
                color: Core.Colors.foreground
                font.family: Core.Colors.fontFamily
                font.pixelSize: 12
                elide: Text.ElideRight
            }
            Text {
                visible: root.view === "connected"
                text: root.selectedNetwork ? "Connected\nSignal: " + Math.round(root.selectedNetwork.signalStrength * 100) + "%" : ""
                color: Core.Colors.muted
                font.family: Core.Colors.fontFamily
                font.pixelSize: 10
            }
            TextInput {
                id: passwordInput
                visible: root.view === "password"
                Layout.fillWidth: true
                height: 32
                echoMode: TextInput.Password
                color: Core.Colors.foreground
                font.family: Core.Colors.fontFamily
                font.pixelSize: 11
                onTextChanged: root.password = text
                onAccepted: root.submitPassword()
                Rectangle {
                    anchors.fill: parent
                    z: -1
                    radius: Core.MenuStyle.sharedRadius.card
                    color: Core.MenuStyle.sharedSurface.notification
                    border.width: Core.MenuStyle.sharedRadius.border
                    border.color: Core.Colors.accent
                    Behavior on color {
                        ColorAnimation {
                            duration: Core.MenuStyle.pressedRule.duration
                            easing.type: Core.MenuStyle.bezierSplineType
                            easing.bezierCurve: Core.MenuStyle.sharedAnimation.fastEffectsCurve
                        }
                    }
                }
            }
            Text {
                visible: root.errorText.length > 0 || Local.WifiService.errorText.length > 0
                text: root.errorText || Local.WifiService.errorText
                color: Core.Colors.accent
                font.family: Core.Colors.fontFamily
                font.pixelSize: 10
            }
            Row {
                Layout.alignment: Qt.AlignHCenter
                spacing: Core.MenuStyle.sharedSpacing.small
                Rectangle {
                    width: 88
                    height: 28
                    radius: Core.MenuStyle.sharedRadius.card
                    color: wifiActionMouse.pressed
                           ? Core.MenuStyle.pressedRule.accentSurface
                           : wifiActionMouse.containsMouse ? Core.MenuStyle.hoverRule.surface : "transparent"
                    border.width: Core.MenuStyle.sharedRadius.border
                    border.color: Core.Colors.accent
                    Behavior on color {
                        ColorAnimation {
                            duration: Core.MenuStyle.hoverRule.duration
                            easing.type: Core.MenuStyle.bezierSplineType
                            easing.bezierCurve: Core.MenuStyle.sharedAnimation.fastEffectsCurve
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        text: root.view === "connected" ? "DISCONNECT" : "CONNECT"
                        color: Core.Colors.accent
                        font.family: Core.Colors.fontFamily
                        font.pixelSize: 9
                    }
                    MouseArea {
                        id: wifiActionMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (root.view === "connected") {
                                Local.WifiService.disconnectNetwork(root.selectedNetwork);
                                root.view = "default";
                            } else {
                                root.submitPassword();
                            }
                        }
                    }
                }
            }
        }

        Row {
            visible: root.view === "default"
            Layout.alignment: Qt.AlignHCenter
            spacing: Core.MenuStyle.sharedSpacing.small
            Repeater {
                model: [
                    { label: "↻", action: "refresh" },
                    { label: "ALL", action: "all" },
                    { label: "SAVED", action: "saved" }
                ]
                delegate: Rectangle {
                    required property var modelData
                    width: modelData.action === "refresh" ? 32 : 60
                    height: 26
                    radius: Core.MenuStyle.sharedRadius.card
                    color: actionMouse.containsMouse ? Core.MenuStyle.hoverRule.surface : "transparent"
                    border.width: Core.MenuStyle.sharedRadius.border
                    border.color: Core.Colors.accent
                    Text {
                        anchors.centerIn: parent
                        text: modelData.label
                        color: Core.Colors.accent
                        font.family: Core.Colors.fontFamily
                        font.pixelSize: 9
                    }
                    MouseArea {
                        id: actionMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (modelData.action === "refresh")
                                Local.WifiService.refresh();
                            else
                                root.view = modelData.action;
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: Local.WifiService.refresh()
}

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
                color: Core.Colors.textColor
                font.family: Core.Colors.fontFamily
                font.weight: Core.Colors.titleWeight
            }
            Text {
                visible: root.view !== "default"
                text: "BACK"
                color: Core.Colors.iconColor
                font.family: Core.Colors.fontFamily
                font.pixelSize: Core.MenuStyle.connectivity.bodyFontSize
                MouseArea { anchors.fill: parent; onClicked: root.view = "default" }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: Core.MenuStyle.connectivity.separatorHeight
            color: Core.Colors.iconColor
            opacity: Core.MenuStyle.connectivity.separatorOpacity
        }

        Core.SharpShape {
            visible: root.view === "default" && Local.WifiService.connected !== null
            Layout.fillWidth: true
            cutBottomRight: false
            height: Core.MenuStyle.connectivity.connectedCardHeight
            fillColor: Core.MenuStyle.dockButtonRule.activeSurface
            strokeWidth: Core.MenuStyle.sharedRadius.border
            strokeColor: Core.Colors.borderColor
            RowLayout {
                anchors.fill: parent
                    anchors.margins: Core.MenuStyle.sharedSpacing.small
                Text {
                    Layout.fillWidth: true
                    text: Local.WifiService.connected ? "●  " + Local.WifiService.connected.name : ""
                    color: Core.Colors.textColor
                    font.family: Core.Colors.fontFamily
                    font.pixelSize: Core.MenuStyle.connectivity.bodyFontSize
                    elide: Text.ElideRight
                }
                Text {
                    text: "DETAILS"
                    color: Core.Colors.mutedText
                    font.family: Core.Colors.fontFamily
                    font.pixelSize: Core.MenuStyle.connectivity.metadataFontSize
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
            delegate: Core.SharpShape {
                required property var modelData
                cutBottomRight: false
                width: networkList.width
                height: Core.MenuStyle.connectivity.networkRowHeight
                fillColor: networkMouse.containsMouse ? Core.MenuStyle.dockButtonRule.activeSurface : Core.MenuStyle.dockButtonRule.idleSurface
                strokeWidth: Core.MenuStyle.sharedRadius.border
                strokeColor: modelData.connected ? Core.Colors.borderColor : Core.Colors.mutedText
                Behavior on fillColor {
                    ColorAnimation {
                        duration: Core.MenuStyle.hoverRule.duration
                        easing.type: Core.MenuStyle.bezierSplineType
                        easing.bezierCurve: Core.MenuStyle.sharedAnimation.fastEffectsCurve
                    }
                }
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Core.MenuStyle.sharedSpacing.medium
                    anchors.rightMargin: Core.MenuStyle.sharedSpacing.medium
                    Text {
                        Layout.fillWidth: true
                        text: modelData.name
                        color: Core.Colors.textColor
                        font.family: Core.Colors.fontFamily
                        font.pixelSize: Core.MenuStyle.connectivity.bodyFontSize
                        elide: Text.ElideRight
                    }
                    Text {
                        text: modelData.connected ? "CONNECTED" : modelData.known ? "SAVED" : ""
                        color: modelData.connected ? Core.Colors.iconColor : Core.Colors.mutedText
                        font.family: Core.Colors.fontFamily
                        font.pixelSize: Core.MenuStyle.connectivity.metadataFontSize
                    }
                    Text {
                        text: WifiSecurityType.toString(modelData.security)
                        color: Core.Colors.mutedText
                        font.family: Core.Colors.fontFamily
                        font.pixelSize: Core.MenuStyle.connectivity.metadataFontSize
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
                color: Core.Colors.textColor
                font.family: Core.Colors.fontFamily
                font.pixelSize: Core.MenuStyle.connectivity.headingFontSize
                elide: Text.ElideRight
            }
            Text {
                visible: root.view === "connected"
                text: root.selectedNetwork ? "Connected\nSignal: " + Math.round(root.selectedNetwork.signalStrength * 100) + "%" : ""
                color: Core.Colors.mutedText
                font.family: Core.Colors.fontFamily
                font.pixelSize: Core.MenuStyle.connectivity.bodyFontSize
            }
            TextInput {
                id: passwordInput
                visible: root.view === "password"
                Layout.fillWidth: true
                height: Core.MenuStyle.connectivity.passwordHeight
                echoMode: TextInput.Password
                color: Core.Colors.textColor
                font.family: Core.Colors.fontFamily
                font.pixelSize: Core.MenuStyle.connectivity.passwordFontSize
                onTextChanged: root.password = text
                onAccepted: root.submitPassword()
                Core.SharpShape {
                    anchors.fill: parent
                    z: -1
                    cutBottomRight: false
                    fillColor: Core.MenuStyle.sharedSurface.notification
                    strokeWidth: Core.MenuStyle.sharedRadius.border
                    strokeColor: Core.Colors.borderColor
                    Behavior on fillColor {
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
                color: Core.Colors.iconColor
                font.family: Core.Colors.fontFamily
                font.pixelSize: Core.MenuStyle.connectivity.bodyFontSize
            }
            Row {
                Layout.alignment: Qt.AlignHCenter
                spacing: Core.MenuStyle.sharedSpacing.small
                Core.SharpShape {
                    width: Core.MenuStyle.connectivity.actionWidth
                    height: Core.MenuStyle.connectivity.actionHeight
                    cutBottomRight: false
                    fillColor: wifiActionMouse.pressed
                           ? Core.MenuStyle.pressedRule.accentSurface
                           : wifiActionMouse.containsMouse ? Core.MenuStyle.dockButtonRule.activeSurface : "transparent"
                    strokeWidth: Core.MenuStyle.sharedRadius.border
                    strokeColor: Core.Colors.borderColor
                    Behavior on fillColor {
                        ColorAnimation {
                            duration: Core.MenuStyle.hoverRule.duration
                            easing.type: Core.MenuStyle.bezierSplineType
                            easing.bezierCurve: Core.MenuStyle.sharedAnimation.fastEffectsCurve
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        text: root.view === "connected" ? "DISCONNECT" : "CONNECT"
                        color: Core.Colors.iconColor
                        font.family: Core.Colors.fontFamily
                        font.pixelSize: Core.MenuStyle.connectivity.metadataFontSize
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
                delegate: Core.SharpShape {
                    required property var modelData
                    cutBottomRight: false
                    width: modelData.action === "refresh" ? Core.MenuStyle.connectivity.refreshWidth : Core.MenuStyle.connectivity.filterWidth
                    height: Core.MenuStyle.connectivity.filterHeight
                    fillColor: actionMouse.containsMouse ? Core.MenuStyle.dockButtonRule.activeSurface : "transparent"
                    strokeWidth: Core.MenuStyle.sharedRadius.border
                    strokeColor: Core.Colors.borderColor
                    Text {
                        anchors.centerIn: parent
                        text: modelData.label
                        color: Core.Colors.iconColor
                        font.family: Core.Colors.fontFamily
                        font.pixelSize: Core.MenuStyle.connectivity.metadataFontSize
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

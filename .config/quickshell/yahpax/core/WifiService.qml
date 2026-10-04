pragma Singleton

import QtQuick
import Quickshell.Networking

QtObject {
    id: root

    readonly property var wifiDevice: {
        const devices = Networking.devices.values || [];
        return devices.find(device => device.type === DeviceType.Wifi) || null;
    }
    readonly property bool available: wifiDevice !== null
    readonly property bool enabled: Networking.wifiEnabled
    readonly property var networks: wifiDevice ? (wifiDevice.networks.values || []) : []
    readonly property var connected: networks.find(network => network.connected) || null
    readonly property var saved: networks.filter(network => network.known)
    property var pendingNetwork: null
    property string errorText: ""

    signal connectionStarted(string ssid)
    signal connectionSucceeded(string ssid)
    signal connectionFailed(string ssid, string reason)

    function refresh() {
        if (!wifiDevice || !enabled)
            return;
        wifiDevice.scannerEnabled = true;
    }

    function setEnabled(value) {
        if (Networking.wifiEnabled !== value)
            Networking.wifiEnabled = value;
    }

    function connectNetwork(network, password) {
        if (!network)
            return;
        errorText = "";
        pendingNetwork = network;
        connectionStarted(network.name);
        if (password && password.length > 0)
            network.connectWithPsk(password);
        else
            network.connect();
    }

    function disconnectNetwork(network) {
        if (network)
            network.disconnect();
    }

    property Connections networkingConnections: Connections {
        target: Networking
        function onWifiEnabledChanged() {
            if (root.enabled)
                root.refresh();
        }
    }

    property Connections pendingConnections: Connections {
        target: root.pendingNetwork
        function onConnectedChanged() {
            if (!root.pendingNetwork || !root.pendingNetwork.connected)
                return;
            const ssid = root.pendingNetwork.name;
            root.pendingNetwork = null;
            root.connectionSucceeded(ssid);
        }
        function onConnectionFailed(reason) {
            if (!root.pendingNetwork)
                return;
            const ssid = root.pendingNetwork.name;
            root.pendingNetwork = null;
            root.errorText = ConnectionFailReason.toString(reason);
            root.connectionFailed(ssid, root.errorText);
        }
    }

    Component.onCompleted: root.refresh()
}

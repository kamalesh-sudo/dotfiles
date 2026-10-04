pragma Singleton

import QtQuick
import Quickshell.Bluetooth

QtObject {
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var devices: Bluetooth.devices.values
    readonly property bool enabled: adapter?.enabled ?? false
    readonly property bool discovering: adapter?.discovering ?? false

    function toggleEnabled() {
        if (adapter)
            adapter.enabled = !adapter.enabled
    }

    function toggleDiscovering() {
        if (adapter)
            adapter.discovering = !adapter.discovering
    }

    function toggleDevice(device) {
        if (device)
            device.connected = !device.connected
    }
}

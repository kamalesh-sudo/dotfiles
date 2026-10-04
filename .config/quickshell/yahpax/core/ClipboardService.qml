pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Single clipboard source of truth. The existing user cliphist.service owns
// capture and storage; this service exposes structured entries to Yahpax UI.
QtObject {
    id: root

    property var items: []
    property bool refreshPending: false

    property Process historyReader: Process {
        command: ["cliphist", "list"]
        environment: ({ "XDG_CACHE_HOME": Quickshell.env("HOME") + "/.cache" })
        running: false
        stdout: StdioCollector {
            onStreamFinished: root.updateItems(this.text)
        }
    }

    property Timer refreshTimer: Timer {
        interval: 250
        repeat: true
        running: true
        onTriggered: root.reload()
    }

    Component.onCompleted: root.reload()

    function updateItems(raw) {
        const next = [];
        for (const line of String(raw || "").split("\n")) {
            const tab = line.indexOf("\t");
            if (tab <= 0) continue;
            const id = line.slice(0, tab).trim();
            const preview = line.slice(tab + 1).trim();
            if (!/^\d+$/.test(id) || preview.length === 0) continue;
            next.push({ id: Number(id), preview: preview, isImage: preview === "[Binary data]" });
        }
        root.items = next;
    }

    function reload() {
        if (refreshPending || historyReader.running) return;
        refreshPending = true;
        Qt.callLater(function() {
            refreshPending = false;
            if (!historyReader.running) historyReader.running = true;
        });
    }

    function copy(item) {
        if (!item || item.id === undefined) return false;
        Quickshell.execDetached(["env",
            "XDG_CACHE_HOME=" + Quickshell.env("HOME") + "/.cache",
            "sh", "-c", "cliphist decode " + String(item.id) + " | wl-copy"]);
        return true;
    }
}

pragma Singleton

import QtQuick
import Quickshell.Io

// Single Yahpax change signal for the existing user cliphist.service. The
// system service owns storage; these listeners only notify the UI after a
// clipboard-owner change has had time to commit to cliphist.
QtObject {
    id: root

    property var history: []
    property bool refreshScheduled: false

    property Process historyReader: Process {
        command: ["cliphist", "list"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                root.history = this.text.split("\n")
                    .filter(line => line.trim().length > 0)
                    .slice(0, 60);
            }
        }
    }

    function start() {
        textWatcher.running = true;
        imageWatcher.running = true;
        refreshHistory();
    }

    function refreshHistory() {
        if (refreshScheduled) return;
        refreshScheduled = true;
        historyReader.running = false;
        Qt.callLater(function() {
            refreshScheduled = false;
            historyReader.running = true;
        });
    }

    property Process textWatcher: Process {
        command: ["wl-paste", "--type", "text", "--watch", "sh", "-c",
                  "sleep 0.15; printf 'yahpax-clipboard-changed\\n'"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: root.refreshHistory()
        }
        onExited: {
            // Keep the UI listener alive if wl-paste exits during a clipboard
            // owner transition or compositor reconnect.
            Qt.callLater(function() {
                if (!textWatcher.running) textWatcher.running = true;
            });
        }
    }

    property Process imageWatcher: Process {
        command: ["wl-paste", "--type", "image", "--watch", "sh", "-c",
                  "sleep 0.15; printf 'yahpax-clipboard-changed\\n'"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: root.refreshHistory()
        }
        onExited: {
            Qt.callLater(function() {
                if (!imageWatcher.running) imageWatcher.running = true;
            });
        }
    }
}

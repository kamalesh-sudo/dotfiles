import QtQuick

Item {

    id: root

    Config {
        id: config
    }

    // Keep the visualizer as a finite surface at the bottom center.
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom


    // ============================================================
    // WINDOW SIZE
    // ============================================================

    width:
        config.visualizerWidth +
        config.margin * 2

    height:
        config.visualizerHeight +
        config.margin * 2

    AudioFrame {

        id: visualizer

        config: config

        width:
            config.visualizerWidth

        height:
            config.visualizerHeight


        // --------------------------------------------------------
        // Horizontal positioning
        // --------------------------------------------------------

        anchors.horizontalCenter:
            config.alignment === "center"
                ? parent.horizontalCenter
                : undefined

        anchors.left:
            config.alignment === "start"
                ? parent.left
                : undefined

        anchors.right:
            config.alignment === "end"
                ? parent.right
                : undefined


        // --------------------------------------------------------
        // Vertical positioning
        // --------------------------------------------------------

        anchors.top:
            config.position === "top"
                ? parent.top
                : undefined

        anchors.bottom:
            config.position === "bottom"
                ? parent.bottom
                : undefined


        anchors.margins:
            config.margin
    }
}

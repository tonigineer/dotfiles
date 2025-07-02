import Quickshell.Io

JsonObject {
    property JsonObject sizes: JsonObject {
        property int innerHeight: 30
        property int windowPreviewSize: 400
        property int trayMenuWidth: 300
        property int batteryWidth: 250
    }

    property JsonObject workspaces: JsonObject {
        property int shown: 6
        property bool showIcons: true
        property real wsSizeMultiplier: 1.65
        property real marginLeft: 8
        property real marginRight: 8

        // property bool rounded: true
        // property bool activeIndicator: true
        // property bool occupiedBg: true
        // property bool showWindows: true
        // property bool activeTrail: true
        // property string label: "  "
        // property string occupiedLabel: "󰮯 "
        // property string activeLabel: "󰮯 "
    }
}

import QtQuick
import Quickshell.Hyprland

import "root:/bar"
import "root:/services"

WidgetContainer {
    id: widgetClock

    property bool showDate: false
    property int idx: 0

    readonly property var formats: [() => Time.time, () => Time.timeLong]

    content: Text {
        text: widgetClock.formats[widgetClock.idx]()
        font.bold: true
    }

    leftClick: function () {
        idx = (idx + 1) % formats.length;
    }

    // rightClick: function () {
    //     Hyprland.dispatch("exec kitty");
    // }

    hoverUnderlineColor: "red"
    hoverBgColor: "green"
}

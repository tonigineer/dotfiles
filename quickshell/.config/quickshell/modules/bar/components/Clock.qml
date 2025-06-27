import QtQuick
import Quickshell.Hyprland

import "root:/common"
import "root:/config"
import "root:/services"
import "root:/widgets"

WidgetContainer {
    id: widgetClock

    property bool showDate: false
    property int currentFormatIdx: 0

    readonly property var formats: [() => Time.time, () => Time.timeLong]

    content: Text {
        text: widgetClock.formats[widgetClock.currentFormatIdx]()
        // renderType: Text.NativeRendering
        color: Config.textColor
        font.family: Config.fontFamily
        font.pointSize: Config.fontSize
        font.bold: true
    }

    leftClick: function () {
        currentFormatIdx = (currentFormatIdx + 1) % formats.length;
    }

    // rightClick: function () {
    //     Hyprland.dispatch("exec kitty");
    // }

    hoverUnderlineColor: Theme.accent_orange
    hoverBgColor: Theme.background_dark
}

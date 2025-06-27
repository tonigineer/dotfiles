import QtQuick
import Quickshell.Hyprland

// import Quickshell
// import Quickshell.Widgets

import "root:/common"
import "root:/config"
import "root:/widgets"

// import "root:/bar"
// import "root:/services"

WidgetContainer {
    id: widgetDistroIcon

    property string source: "arch"
    property string iconFolder: "root:/assets/icons"  // The folder to check first

    // TODO: using .svg instead. Problem, they are all blurry. What is
    // happening here?
    content: Text {
        text: ""
        color: Config.bar.widgetIcon.iconColor
        font.pixelSize: Config.bar.widgetIcon.iconSize
    }

    leftClick: function () {
        Hyprland.dispatch("exec uwsm app -- kitty");
    }
    rightClick: function () {
        Hyprland.dispatch("exec kitty");
    }
    middleClick: function () {
        Hyprland.dispatch("exec uwsm app -- rofi -show drun");
    }
}

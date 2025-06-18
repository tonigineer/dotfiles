import QtQuick
import Quickshell.Hyprland

// import "root:/bar"
// import "root:/services"

import QtQuick
import Quickshell
import Quickshell.Widgets

WidgetContainer {
    id: widgetDistroIcon

    property string source: "arch"
    property string iconFolder: "root:/assets/icons"  // The folder to check first
    // width: 30
    height: 30

    // TODO: using .svg instead. Problem, they are all blurry. What is
    // happening here?
    content: Text {
        text: ""
        font.pixelSize: 26
    }

    leftClick: function () {
        Hyprland.dispatch("exec kitty");
    }
    rightClick: function () {
        Hyprland.dispatch("exec kitty");
    }
    middleClick: function () {
        Hyprland.dispatch("exec rofi -show drun");
    }

    hoverUnderlineColor: "transparent"
    hoverBgColor: "orange"
    hoverColor: "red"
}

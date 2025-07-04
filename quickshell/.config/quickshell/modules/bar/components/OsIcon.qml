import "root:/widgets"
import "root:/services"
import "root:/utils"
import "root:/config"

StyledText {
    text: Icons.osIcon
    font.pointSize: Appearance.font.size.large
    font.family: Appearance.font.family.mono
    color: Colors.palette.m3tertiary
}

// WidgetContainer {
//     id: widgetDistroIcon

//     property string source: "arch"
//     property string iconFolder: "root:/assets/icons"  // The folder to check first

//     // TODO: using .svg instead. Problem, they are all blurry. What is
//     // happening here?
//     content: Text {
//         text: ""
//         color: Config.bar.widgetIcon.iconColor
//         font.pixelSize: Config.bar.widgetIcon.iconSize
//     }

//     leftClick: function () {
//         Hyprland.dispatch("exec uwsm app -- kitty");
//     }
//     rightClick: function () {
//         Hyprland.dispatch("exec kitty");
//     }
//     middleClick: function () {
//         Hyprland.dispatch("exec uwsm app -- rofi -show drun");
//     }
// }

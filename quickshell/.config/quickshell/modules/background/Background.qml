import "../../widgets"
import Quickshell
import Quickshell.Wayland

Variants {
    model: Quickshell.screens

    StyledWindow {
        id: win

        required property ShellScreen modelData

        screen: modelData
        name: "background"
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Background
        color: "black"

        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        anchors.right: true

        Wallpaper {}

        visible: false  // workaround for launcher not showing entries. loading background helps here, dont know why
    }
}

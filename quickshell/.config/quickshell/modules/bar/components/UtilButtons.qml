import "root:/widgets"
import "root:/services"
import "root:/utils"
import "root:/config"
import Quickshell
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Controls

Item {
    id: root

    property color colour: Colors.palette.m3secondary
    readonly property real spacing: Appearance.spacing.normal

    readonly property Item hyprpicker: hyprpicker
    readonly property Item hyprshot: hyprshot
    property bool hyprildeIsRunning: HyprlandData.hypridleIsRunning

    clip: true
    implicitHeight: parent.implicitHeight
    implicitWidth: hypridle.implicitWidth + hyprpicker.implicitWidth + hyprshot.implicitWidth + spacing * 4

    MaterialIcon {
        id: hypridle

        animate: true
        text: HyprlandData.hypridleIsRunning ? "emoji_food_beverage" : "coffee_maker"
        color: HyprlandData.hypridleIsRunning ? root.colour : Colors.palette.m3error

        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: spacing

        StateLayer {
            anchors.fill: undefined
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: 1
            implicitWidth: parent.implicitHeight + Appearance.padding.small * 2
            implicitHeight: implicitWidth
            radius: Appearance.rounding.full
            color: Colors.palette.yellow

            function onClicked(): void {
                Hyprland.dispatch(["exec systemctl --user status --quiet hypridle.service | grep inactive && systemctl --user start --now hypridle.service || systemctl --user stop hypridle.service"]);
                HyprlandData.updateHypridle();
            }
        }
    }

    MaterialIcon {
        id: hyprpicker

        anchors.verticalCenter: parent.verticalCenter
        anchors.right: hypridle.left
        anchors.rightMargin: spacing

        animate: true
        text: "colorize"
        color: root.colour

        StateLayer {
            anchors.fill: undefined
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: 1

            implicitWidth: parent.implicitHeight + Appearance.padding.small * 2
            implicitHeight: implicitWidth

            radius: Appearance.rounding.full
            color: Colors.palette.yellow

            function onClicked(): void {
                Hyprland.dispatch("exec hyprpicker -a");
            }
        }
    }

    MaterialIcon {
        id: hyprshot

        animate: true
        text: "screenshot_region"
        color: root.colour

        anchors.verticalCenter: parent.verticalCenter
        anchors.right: hyprpicker.left
        anchors.rightMargin: spacing
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Appearance.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.curves.emphasized
        }
    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: Appearance.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.curves.emphasized
        }
    }
}

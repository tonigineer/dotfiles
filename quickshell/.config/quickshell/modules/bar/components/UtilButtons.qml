import "root:/widgets"
import "root:/services"
import "root:/utils"
import "root:/config"
import Quickshell
import Quickshell.Services.UPower
import QtQuick

Item {
    id: root

    property color colour: Colors.palette.m3secondary
    readonly property real spacing: Appearance.spacing.normal

    readonly property Item network: hyprpicker
    readonly property Item battery: hyprshot

    clip: true
    implicitHeight: parent.implicitHeight
    implicitWidth: hyprpicker.implicitWidth + hyprshot.implicitWidth + spacing * 4

    MaterialIcon {
        id: hyprpicker

        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
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

        StateLayer {
            anchors.fill: undefined
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: 1

            implicitWidth: parent.implicitHeight + Appearance.padding.small * 2
            implicitHeight: implicitWidth

            radius: Appearance.rounding.full
            color: Colors.palette.yellow

            function onClicked(): void {
                Hyprland.dispatch("exec hyprshot --freeze --clipboard-only --mode region --silent");
            }
        }
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

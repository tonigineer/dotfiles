// qmllint disable missing-property

import "../../../widgets"
import "../../../services"
import "../../../services" as S
import "../../../config"
import QtQuick

Item {
    id: root
    property color colour: Colors.palette.m3secondary
    readonly property real spacing: Appearance.spacing.normal

    readonly property Item hyprpicker: hyprpicker
    readonly property Item hyprshot: hyprshot

    clip: true
    implicitHeight: parent.implicitHeight
    implicitWidth: hypridle.implicitWidth + hyprpicker.implicitWidth + hyprshot.implicitWidth + spacing * 4

    MaterialIcon {
        id: hypridle

        animate: true
        text: S.Hypridle.active ? "mode_standby" : "mode_night"
        color: S.Hypridle.active ? root.colour : Colors.palette.m3error

        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: root.spacing

        StateLayer {
            anchors.fill: undefined
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: 1
            implicitWidth: parent.implicitHeight + Appearance.padding.small * 2
            implicitHeight: implicitWidth
            radius: Appearance.rounding.full
            color: Colors.palette.yellow

            function onClicked(): void {
                S.Hypridle.toggle();
            }
        }
    }

    MaterialIcon {
        id: hyprpicker

        anchors.verticalCenter: parent.verticalCenter
        anchors.right: hypridle.left
        anchors.rightMargin: root.spacing

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
        anchors.rightMargin: root.spacing
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

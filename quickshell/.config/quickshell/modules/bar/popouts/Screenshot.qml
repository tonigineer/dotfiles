pragma ComponentBehavior: Bound

import "root:/widgets"
import "root:/services"
import "root:/config"
import QtQuick
import QtQuick.Controls

Row {
    id: screenshotBar
    spacing: Appearance.spacing.large
    anchors.horizontalCenter: parent?.horizontalCenter

    component ShotButton: StyledRect {
        required property string iconName
        required property string hyprCommand

        radius: Appearance.rounding.normal
        implicitWidth: icon.implicitHeight + Appearance.padding.normal * 2
        implicitHeight: icon.implicitHeight + Appearance.padding.normal * 2
        color: "transparent"

        StateLayer {
            radius: parent.radius
            color: Colors.palette.m3primary
            onClicked: Hyprland.dispatch(`exec ${hyprCommand}`)
        }

        MaterialIcon {
            id: icon
            anchors.centerIn: parent
            text: iconName
            font.pointSize: Appearance.font.size.larger * 2
            color: Colors.palette.m3onSurface
            fill: 1
        }
    }

    ShotButton {
        iconName: "screenshot_monitor"
        hyprCommand: "hyprshot -m output"
    }

    ShotButton {
        iconName: "screenshot_tablet"
        hyprCommand: "hyprshot -m window"
    }

    ShotButton {
        iconName: "screenshot_frame_2"
        hyprCommand: "hyprshot -m region"
    }
}

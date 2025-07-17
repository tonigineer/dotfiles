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
        required property string label

        radius: Appearance.rounding.normal
        implicitWidth: icon.implicitWidth * 2 + Appearance.padding.normal * 2
        implicitHeight: icon.implicitHeight + labelItem.implicitHeight + Appearance.padding.normal * 3    // space for label
        color: "transparent"

        StateLayer {
            radius: parent.radius
            color: Colors.palette.m3primary
            onClicked: Hyprland.dispatch(`exec ${hyprCommand}`)
        }

        Column {
            anchors.centerIn: parent
            spacing: Appearance.spacing.smaller

            MaterialIcon {
                id: icon
                anchors.horizontalCenter: parent.horizontalCenter
                text: iconName
                font.pointSize: Appearance.font.size.larger * 2
                color: Colors.palette.m3onSurface
                fill: 1
            }

            StyledText {
                id: labelItem
                text: label
                font.pointSize: Appearance.font.size.small
                color: Colors.palette.m3surfaceVariant
                horizontalAlignment: Text.AlignHCenter
                width: screenshotBar.width
                elide: Text.ElideLeft
            }
        }
    }

    ShotButton {
        iconName: "screenshot_monitor"
        hyprCommand: "hyprshot -m output -z -o ~/Pictures/Screenshots"
        label: "Screen"
    }

    ShotButton {
        iconName: "screenshot_tablet"
        hyprCommand: "hyprshot -m window -z -o ~/Pictures/Screenshots"
        label: "Window"
    }

    ShotButton {
        iconName: "screenshot_frame_2"
        hyprCommand: "hyprshot -m region -z -o ~/Pictures/Screenshots"
        label: "Region"
    }
}

import "root:/widgets"
import "root:/services"
import "root:/utils"
import "root:/config"

import Quickshell
import QtQuick

StyledText {
    id: icon

    text: Icons.osIcon
    font.pointSize: Appearance.font.size.large + 8
    font.family: Appearance.font.family.mono
    color: SystemStats.updatesList.length > 0 ? Colors.palette.m3tertiary : Colors.palette.blue

    // Rectangle {
    //     id: underline
    //     visible: false
    //     anchors.left: parent.left
    //     anchors.right: parent.right
    //     anchors.bottom: parent.bottom

    //     anchors.leftMargin: 0
    //     anchors.rightMargin: 0
    //     radius: height / 2
    //     antialiasing: true
    //     height: 2
    //     color: SystemStats.updatesList.length > 0 ? Colors.palette.m3tertiary : "transparent"
    //     z: -1
    // }

    Rectangle {
        id: badge
        visible: SystemStats.updatesList.length > 0
        height: 12
        radius: height / 1.5
        antialiasing: true
        color: Colors.palette.m3surfaceContainer
        width: Math.max(height, badgeText.paintedWidth + 6)

        anchors.right: icon.right
        anchors.top: icon.top
        anchors.rightMargin: -10
        anchors.topMargin: 20
        z: 1

        Text {
            id: badgeText
            anchors.centerIn: parent
            text: SystemStats.updatesList.length
            color: Colors.palette.m3neutral_paletteKeyColor
            font.pixelSize: 9
            font.bold: true
        }
    }
}

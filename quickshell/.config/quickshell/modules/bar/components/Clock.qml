import QtQuick

import "root:/widgets"
import "root:/services"
import "root:/config"

Row {
    id: root

    property color colour: Colors.palette.m3tertiary

    spacing: Appearance.spacing.small

    MaterialIcon {
        id: icon

        text: "calendar_month"
        color: root.colour
        anchors.verticalCenter: parent.verticalCenter
    }

    StyledText {
        id: text

        anchors.verticalCenter: parent.verticalCenter
        anchors.top: icon.top

        verticalAlignment: StyledText.AlignVCenter
        text: Time.format("hh:mm")
        font.pointSize: Appearance.font.size.smaller
        font.family: Appearance.font.family.mono
        color: root.colour
    }
}

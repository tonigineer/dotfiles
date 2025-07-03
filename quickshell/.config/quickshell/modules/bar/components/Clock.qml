import "root:/widgets"
import "root:/services"
import "root:/config"
import QtQuick

Row {
    id: root

    property color colour: Colors.palette.m3onSurface
    property bool showDate: false
    property string timeFormat: showDate ? "dd.MMMM, hh:mm" : "hh:mm"

    spacing: Appearance.spacing.small

    // MaterialIcon {
    //     id: icon

    //     text: "calendar_month"
    //     color: root.colour
    //     anchors.verticalCenter: parent.verticalCenter
    // }

    StyledText {
        id: text

        anchors.verticalCenter: parent.verticalCenter
        // anchors.top: icon.top

        verticalAlignment: StyledText.AlignVCenter
        text: Time.format(root.timeFormat)
        font.pointSize: Appearance.font.size.smaller
        font.family: Appearance.font.family.mono
        color: root.colour

        // MouseArea {
        //     anchors.fill: parent
        //     acceptedButtons: Qt.LeftButton
        //     onClicked: root.showDate = !root.showDate

        //     cursorShape: Qt.PointingHandCursor
        // }
    }
}

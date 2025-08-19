// import "../services" as S
import QtQuick

MouseArea {
    // TODO: Hover effect needs to be implemented
    // property color color: S.Config.theme.on_surface
    // property real radius: parent?.radius ?? 0
    // hoverEnabled: true
    id: root

    property bool disableCursor: false

    anchors.fill: parent
    cursorShape: disableCursor ? undefined : Qt.PointingHandCursor

    function onClicked(): void {
    }

    onClicked: event => onClicked(event)
}

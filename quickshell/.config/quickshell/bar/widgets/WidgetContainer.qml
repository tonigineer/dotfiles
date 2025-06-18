import QtQuick
import QtQuick.Layouts
import Quickshell

// TODO: TOOLTIPS

Rectangle {
    id: root
    Layout.preferredWidth: contentContainer.implicitWidth + 10
    Layout.preferredHeight: 30

    required property Item content

    property var leftClick: function () {}
    property var rightClick: function () {}
    property var middleClick: function () {}
    property string hoverColor: "transparent"
    property string hoverBgColor: "transparent"
    property string hoverUnderlineColor: "transparent"

    property int leftPadding: 0
    property int rightPadding: 0

    property Item mouseArea: mouseArea

    color: {
        if (mouseArea.containsMouse)
            return hoverBgColor;
        return "transparent";
    }

    Rectangle {
        id: wsLine

        visible: mouseArea.containsMouse
        width: parent.width
        height: 2

        color: {
            if (mouseArea.containsMouse)
                return parent.hoverUnderlineColor;
            return "transparent";
        }
        anchors.bottom: parent.bottom
    }

    states: [
        State {
            when: mouseArea.containsMouse
            PropertyChanges {
                target: root
            }
        }
    ]

    Behavior on color {
        ColorAnimation {
            duration: 200
        }
    }

    Item {
        id: contentContainer
        implicitWidth: content.implicitWidth
        implicitHeight: content.implicitHeight
        anchors.centerIn: parent
        children: content
    }

    MouseArea {
        id: mouseArea
        anchors.fill: root
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        acceptedButtons: Qt.MiddleButton | Qt.LeftButton | Qt.RightButton
        onPressed: event => {
            if (event.button === Qt.LeftButton) {
                root.leftClick();
            } else if (event.button === Qt.RightButton) {
                root.rightClick();
            } else if (event.button === Qt.MiddleButton) {
                root.middleClick();
            }
        }
    }
}

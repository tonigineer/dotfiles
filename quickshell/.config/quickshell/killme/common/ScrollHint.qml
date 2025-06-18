import QtQuick
import QtQuick.Layouts

import "root:/"
import "root:/config"
import "root:/common"

Revealer {
    id: root
    property string icon
    property string side: "left"
    property string tooltipText: ""

    MouseArea {
        anchors.right: root.side === "left" ? parent.right : undefined
        anchors.left: root.side === "right" ? parent.left : undefined
        implicitWidth: contentColumnLayout.implicitWidth
        implicitHeight: contentColumnLayout.implicitHeight
        property bool hovered: false

        hoverEnabled: true
        onEntered: hovered = true
        onExited: hovered = false
        acceptedButtons: Qt.NoButton

        ColumnLayout {
            id: contentColumnLayout
            anchors.centerIn: parent
            spacing: -5

            // https://fonts.google.com/icons
            MaterialSymbol {
                Layout.leftMargin: 5
                Layout.rightMargin: 5
                text: "keyboard_arrow_up"
                iconSize: 14
                color: Vanity.theme.text_secondary
            }
            MaterialSymbol {
                Layout.leftMargin: 5
                Layout.rightMargin: 5
                text: root.icon
                iconSize: 14
                color: Vanity.theme.text_secondary
            }
            MaterialSymbol {
                Layout.leftMargin: 5
                Layout.rightMargin: 5
                text: "keyboard_arrow_down"
                iconSize: 14
                color: Vanity.theme.text_secondary
            }
        }
    }
}

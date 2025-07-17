import "root:/widgets"
import "root:/services"
import "root:/config"
import QtQuick

Item {
    id: root

    required property var modelData
    implicitHeight: Config.launcher.sizes.itemHeight

    anchors.left: parent?.left
    anchors.right: parent?.right

    StateLayer {
        radius: Appearance.rounding.full
        onClicked: {
            const mac = root.modelData.address;
            let cmd;

            if (root.modelData.connected) {
                cmd = `bluetoothctl disconnect ${mac}`;
            } else if (!root.modelData.paired) {
                cmd = `bluetoothctl pair ${mac} && \
                        bluetoothctl trust ${mac} && \
                        bluetoothctl connect ${mac}`;
            } else {
                cmd = `bluetoothctl connect ${mac}`;
            }

            Hyprland.dispatch(`exec ${cmd}`);
        }
    }

    Item {
        anchors.fill: parent
        anchors.margins: Appearance.padding.smaller
        anchors.leftMargin: Appearance.padding.larger
        anchors.rightMargin: Appearance.padding.larger

        MaterialIcon {
            id: icon
            anchors.verticalCenter: parent.verticalCenter
            font.pointSize: Appearance.font.size.extraLarge
            color: root.modelData.connected ? Colors.palette.m3onSurface : Colors.palette.m3surfaceVariant
            text: root.modelData.connected ? "bluetooth_connected" : root.modelData.trusted ? "verified" : "verified_off"
        }

        Column {
            anchors.left: icon.right
            anchors.leftMargin: Appearance.spacing.normal
            anchors.verticalCenter: icon.verticalCenter
            width: root.width - icon.width - Appearance.rounding.normal * 2
            spacing: 0

            StyledText {
                text: root.modelData.name
                font.pointSize: Appearance.font.size.normal
                color: root.modelData.connected ? Colors.palette.m3onSurface : Colors.palette.m3surfaceVariant
                elide: Text.ElideRight
                width: parent.width
            }

            StyledText {
                text: root.modelData.address
                font.pointSize: Appearance.font.size.small
                color: Colors.alpha(Colors.palette.m3outline, true)
            }
        }
    }
}

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
            root.modelData.state === NetworkAdapter.DeviceState.Disconnected
                ? Hyprland.dispatch(`exec kitty --title centerfloat -e nmcli --ask device wifi connect "${modelData.ssid}"`)
                : Hyprland.dispatch(`exec nmcli connection down id ${modelData.ssid}`);
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

            text: root.modelData.strength > 80 ? "signal_wifi_4_bar" : root.modelData.strength > 60 ? "network_wifi_3_bar" : root.modelData.strength > 40 ? "network_wifi_2_bar" : root.modelData.strength > 20 ? "network_wifi_1_bar" : "signal_wifi_0_bar"
        }

        Column {
            anchors.left: icon.right
            anchors.leftMargin: Appearance.spacing.normal
            anchors.verticalCenter: icon.verticalCenter
            width: root.width - icon.width - Appearance.rounding.normal * 2
            spacing: 0

            StyledText {
                text: root.modelData.ssid
                font.pointSize: Appearance.font.size.normal
                color: root.modelData.state === NetworkAdapter.DeviceState.Connected ? Colors.palette.m3onSurface : Colors.palette.m3surfaceVariant
                elide: Text.ElideRight
                width: parent.width
            }

            StyledText {
                text: `${root.modelData.strength}% ${root.modelData.state === NetworkAdapter.DeviceState.Connected ? "connected" : ""}`
                font.pointSize: Appearance.font.size.small
                color: Colors.alpha(Colors.palette.m3outline, true)
            }
        }
    }
}

import "root:/widgets"
import "root:/services"
import "root:/config"
import QtQuick
import QtQuick.Controls

Column {
    id: root

    spacing: Appearance.spacing.small

    StyledText {
        text: qsTr("Connected to: %1").arg(Network.active?.ssid ?? "None")
    }

    StyledText {
        text: qsTr("Strength: %1/100").arg(Network.active?.strength ?? 0)
    }

    StyledText {
        text: qsTr("Frequency: %1 MHz").arg(Network.active?.frequency ?? 0)
    }
}

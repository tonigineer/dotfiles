import "root:/widgets"
import "root:/services"
import "root:/utils"
import "root:/config"
import Quickshell
import Quickshell.Services.UPower
import QtQuick

Item {
    id: root

    property color colour: Colors.palette.m3secondary
    readonly property real spacing: Appearance.spacing.normal

    readonly property Item network: network
    readonly property Item networkSpeeds: networkSpeeds
    readonly property Item battery: battery
    readonly property Item bluetooth: bluetooth

    clip: true
    implicitHeight: parent.implicitHeight
    implicitWidth: network.implicitWidth + networkSpeeds.implicitWidth + bluetooth.implicitWidth + battery.implicitWidth + spacing * 4

    MaterialIcon {
        id: battery

        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: spacing

        animate: true
        text: {
            if (!UPower.displayDevice.isLaptopBattery) {
                if (PowerProfiles.profile === PowerProfile.PowerSaver)
                    return "energy_savings_leaf";
                if (PowerProfiles.profile === PowerProfile.Performance)
                    return "rocket_launch";
                return "balance";
            }

            const perc = UPower.displayDevice.percentage;
            const charging = !UPower.onBattery;
            if (perc === 1)
                return charging ? "battery_charging_full" : "battery_full";
            let level = Math.floor(perc * 7);
            if (charging && (level === 4 || level === 1))
                level--;
            return charging ? `battery_charging_${(level + 3) * 10}` : `battery_${level}_bar`;
        }
        color: !UPower.onBattery || UPower.displayDevice.percentage > 0.2 ? root.colour : Colors.palette.m3error
        fill: 1
    }

    MaterialIcon {
        id: network

        animate: true
        text: NetworkAdapter.materialSymbol
        color: root.colour

        anchors.verticalCenter: parent.verticalCenter
        anchors.right: battery.left
        anchors.rightMargin: spacing
    }

    Item {
        id: networkSpeeds

        anchors.verticalCenter: parent.verticalCenter
        anchors.right: network.left
        anchors.bottom: parent.bottom
        implicitWidth: downloadArrow.implicitWidth + downloadValue.implicitWidth
        // implicitHeight: downloadArrow.implicitHeight + downloadValue.implicitHeight

        MaterialIcon {
            id: uploadArrow

            anchors.bottom: parent.bottom
            anchors.right: parent.right
            animate: true

            text: "arrow_drop_up"
            color: NetworkAdapter.uploadMBs >= 0.1 ? Colors.palette.m3error : Colors.palette.m3inverseOnSurface
            font.pointSize: Appearance.font.size.large
            font.weight: NetworkAdapter.uploadMBs >= 0.1 ? Font.Bold : Font.DemiBold
        }

        MaterialIcon {
            id: downloadArrow

            anchors.top: networkSpeeds.top
            anchors.right: parent.right
            animate: true

            text: "arrow_drop_down"
            color: NetworkAdapter.downloadMBs >= 0.1 ? Colors.palette.rosewater : Colors.palette.m3inverseOnSurface

            font.pointSize: Appearance.font.size.large
            font.weight: NetworkAdapter.downloadMBs >= 0.1 ? Font.Bold : Font.DemiBold
        }

        Text {
            id: uploadValue

            anchors.bottom: parent.top
            anchors.bottomMargin: -10
            anchors.left: parent.left

            text: `${NetworkAdapter.uploadMBs >= 10 ? "" : " "}${NetworkAdapter.uploadMBs.toFixed(1)}`
            color: root.colour
            font.pixelSize: 9
            font.bold: true
            font.family: Appearance.font.family.mono
        }

        Text {
            id: downloadValue
            anchors.top: parent.bottom
            anchors.topMargin: -10
            anchors.left: parent.left

            text: `${NetworkAdapter.downloadMBs >= 10 ? "" : " "}${NetworkAdapter.downloadMBs.toFixed(1)}`
            color: root.colour
            font.pixelSize: 9
            font.bold: true
            font.family: Appearance.font.family.mono
        }
    }

    MaterialIcon {
        id: bluetooth

        anchors.verticalCenter: parent.verticalCenter
        anchors.right: networkSpeeds.left
        anchors.rightMargin: spacing

        animate: true
        text: Bluetooth.powered ? "bluetooth" : "bluetooth_disabled"
        color: root.colour
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Appearance.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.curves.emphasized
        }
    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: Appearance.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.anim.curves.emphasized
        }
    }
}

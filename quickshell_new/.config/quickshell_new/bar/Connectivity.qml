import "../widgets" as W
import "../services" as S
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower

RowLayout {
    id: root

    spacing: 10
    property color defaultColor: S.Config.theme.secondary

    readonly property Item network: network
    readonly property Item networkSpeeds: networkSpeeds
    readonly property Item battery: battery
    readonly property Item bluetooth: bluetooth

    clip: true

    implicitHeight: parent.implicitHeight
    implicitWidth: bluetooth.implicitWidth + networkSpeeds.implicitWidth + network.implicitWidth + battery.implicitWidth + root.spacing * 4

    W.MaterialIcon {
        id: bluetooth

        text: S.BluetoothAdapter.materialSymbol
        color: root.defaultColor
    }

    NetworkSpeeds {
        id: networkSpeeds
    }

    W.MaterialIcon {
        id: network

        text: S.NetworkAdapter.materialSymbol
        color: root.defaultColor
    }

    W.MaterialIcon {
        id: battery

        text: {
            if (!UPower.displayDevice.isLaptopBattery) {
                // if (PowerProfiles.profile === PowerProfile.PowerSaver)
                //     return "energy_savings_leaf";
                // if (PowerProfiles.profile === PowerProfile.Performance)
                //     return "rocket_launch";
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
        color: !UPower.onBattery || UPower.displayDevice.percentage > 0.2 ? root.defaultColor : S.Config.theme.error
        fill: 1
    }

    // qmllint disable missing-property
    Behavior on implicitWidth {
        NumberAnimation {
            duration: S.Config.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: S.Config.anim.curves.emphasized
        }
    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: S.Config.anim.durations.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: S.Config.anim.curves.emphasized
        }
    }
}

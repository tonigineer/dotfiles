// pragma ComponentBehavior: Bound

import "root:/modules/launcher"
import "root:/widgets"
import "root:/services"
import "root:/config"
import Quickshell
import QtQuick
import QtQuick.Controls

Column {
    id: root
    spacing: Appearance.spacing.small

    Row {
        spacing: Appearance.spacing.large
        anchors.horizontalCenter: parent.horizontalCenter

        AdapterToggle {
            activeIcon: NetworkAdapter.wifiState === NetworkAdapter.DeviceState.Disconnected ? "signal_wifi_statusbar_not_connected" : "wifi"
            inactiveIcon: "wifi_off"
            active: NetworkAdapter.wifiState > NetworkAdapter.DeviceState.NotAvailable
            toggleFunction: NetworkAdapter.toggleWifi
        }

        AdapterToggle {
            activeIcon: "lan"
            inactiveIcon: "lan"
            active: NetworkAdapter.ethernetState === NetworkAdapter.DeviceState.Connected
            toggleFunction: NetworkAdapter.toggleEthernet
        }
    }

    component AdapterToggle: StyledRect {
        required property bool active
        required property string activeIcon
        required property string inactiveIcon
        required property var toggleFunction

        radius: Appearance.rounding.full
        implicitWidth: icon.implicitHeight + Appearance.padding.normal * 2
        implicitHeight: icon.implicitHeight + Appearance.padding.normal * 2
        color: active ? Colors.palette.m3primary : Colors.palette.m3surfaceContainer

        StateLayer {
            radius: parent.radius
            color: "transparent"
            onClicked: toggleFunction()
        }

        MaterialIcon {
            id: icon
            anchors.centerIn: parent
            text: active ? activeIcon : inactiveIcon
            font.pointSize: Appearance.font.size.larger
            color: active ? Colors.palette.m3onPrimary : Colors.palette.m3onSurface
            fill: active ? 1 : 0

            Behavior on fill {
                NumberAnimation {
                    duration: Appearance.anim.durations.normal
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Appearance.anim.curves.standard
                }
            }
        }
    }

    Rectangle {
        id: listBox

        color: Colors.palette.m3surfaceContainer
        radius: Appearance.rounding.normal
        width: 300
        height: Math.min(wifiList.contentHeight, 250)

        ListView {
            id: wifiList
            model: ScriptModel {
                id: wifiScriptModel
                values: NetworkAdapter.wifiAvailableNetworks
            }
            clip: true
            anchors.fill: parent
            delegate: NetworkWifiItem { }

            ScrollBar.vertical: StyledScrollBar {}
        }
    }

    Connections {
        target: NetworkAdapter
        function update() {
            wifiScriptModel.values = NetworkAdapter.wifiAvailableNetworks;
        }
    }
}

pragma ComponentBehavior: Bound

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
            activeIcon: BluetoothAdapter.powered ? "bluetooth" : "bluetooth_disabled"
            inactiveIcon: "bluetooth_disabled"
            active: BluetoothAdapter.powered
            toggleFunction: BluetoothAdapter.toggleBluetooth
        }

        AdapterToggle {
            activeIcon: "progress_activity"
            inactiveIcon: "barcode_reader"
            active: BluetoothAdapter.discovering
            toggleFunction: BluetoothAdapter.startScanning
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

            NumberAnimation on rotation {
                from: 0
                to: 360
                duration: 1500
                easing.type: Easing.Linear
                running: active && activeIcon === "progress_activity"
                loops: Animation.Infinite
                onRunningChanged: if (!running)
                    icon.rotation = 0
            }

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
        radius: Appearance.rounding.large
        width: 300
        height: Math.min(deviceList.contentHeight, 250)

        ListView {
            id: deviceList
            model: ScriptModel {
                id: deviceScriptModel
                values: BluetoothAdapter.devices
            }
            clip: true
            anchors.fill: parent
            delegate: BluetoothItem {}

            ScrollBar.vertical: StyledScrollBar {}
        }
    }

    Connections {
        target: BluetoothAdapter
        function update() {
            deviceScriptModel.values = BluetoothAdapter.devices;
        }
    }
}

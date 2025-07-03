import "components" as Components
// import "components/workspaces" as HyprlandWorkspaces
import "root:/config"
import "root:/common"
import "root:/services"
import "root:/widgets"
import "root:/modules/bar/popouts" as BarPopouts
import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Item {
    id: bar

    property ShellScreen modelData
    required property BarPopouts.Wrapper popouts

    function checkPopout(x: real): void {
        // const spacing = Appearance.spacing.small;
        // const aw = activeWindow.child;
        // const awy = activeWindow.y + aw.y;

        // const ty = tray.y;
        // const th = tray.implicitHeight;
        // const trayItems = tray.items;

        // const n = statusIconsInner.network;
        // const ny = statusIcons.y + statusIconsInner.y + n.y - spacing / 2;

        // const bls = statusIcons.y + statusIconsInner.y + statusIconsInner.bs - spacing / 2;
        // const ble = statusIcons.y + statusIconsInner.y + statusIconsInner.be + spacing / 2;

        // const b = statusIconsInner.battery;
        // const by = statusIcons.y + statusIconsInner.y + b.y - spacing / 2;
        //
        // rightSection.clock.x;
        // rightSection.power.x;
        const n = statusIconsInner.network;
        const network_x = rightSection.x + statusIcons.x + statusIconsInner.x + n.x + Appearance.spacing.normal * 2;
        const network_dx = n.implicitWidth;

        // console.log(x);
        // console.log(network_x);
        // console.log(network_dx);

        // console.log(network_x + n.implicitWidth / 2);

        if (x > network_x && x < network_x + network_dx)
        // if (y >= awy && y <= awy + aw.implicitHeight) {
        //     popouts.currentName = "activewindow";
        //     popouts.currentCenter = Qt.binding(() => activeWindow.y + aw.y + aw.implicitHeight / 2);
        //     popouts.hasCurrent = true;
        // } else if (y > ty && y < ty + th) {
        //     const index = Math.floor(((y - ty) / th) * trayItems.count);
        //     const item = trayItems.itemAt(index);

        //     popouts.currentName = `traymenu${index}`;
        //     popouts.currentCenter = Qt.binding(() => tray.y + item.y + item.implicitHeight / 2);
        //     popouts.hasCurrent = true;
        // } else if (y >= ny && y <= ny + n.implicitHeight + spacing) {
        //     popouts.currentName = "network";
        //     popouts.currentCenter = Qt.binding(() => statusIcons.y + statusIconsInner.y + n.y + n.implicitHeight / 2);
        //     popouts.hasCurrent = true;
        // } else if (y >= bls && y <= ble) {
        //     popouts.currentName = "bluetooth";
        //     popouts.currentCenter = Qt.binding(() => statusIcons.y + statusIconsInner.y + statusIconsInner.bs + (statusIconsInner.be - statusIconsInner.bs) / 2);
        //     popouts.hasCurrent = true;
        // } else if (y >= by && y <= by + b.implicitHeight + spacing) {
        //     popouts.currentName = "battery";
        //     popouts.currentCenter = Qt.binding(() => statusIcons.y + statusIconsInner.y + b.y + b.implicitHeight / 2);
        //     popouts.hasCurrent = true;
        {
            popouts.currentName = "network";
            popouts.currentCenter = Qt.binding(() => rightSection.x + statusIcons.x + statusIconsInner.x + n.x + Appearance.spacing.normal * 2);
            popouts.hasCurrent = true;
        } else {
            console.log("close")
            popouts.hasCurrent = false;
        }
    }

    implicitHeight: 30

    Rectangle {
        id: background
        // radius: 20
        // border.width: 0
        // border.color: "white"
        anchors.fill: parent
        color: Colors.palette.m3background
    }

    RowLayout {
        id: content
        spacing: 20

        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        anchors.centerIn: parent
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20

        RowLayout {
            id: leftSection
            spacing: 20
            Layout.alignment: Qt.AlignLeft
            Layout.fillWidth: true

            Components.OsIcon {}

            // TODO: Brightness and Audio scrolling somewhere else
            // monitor: Brightness.getMonitorForScreen(root.screen)
            Components.ActiveWindow {}
        }

        Item {
            Layout.fillWidth: true
        }

        RowLayout {
            id: centerSection

            spacing: 20
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillWidth: true

            // TODO: below truely centers it, but throws warning
            //   WARN scene: QML RowLayout at **/modules/bar/Bar.qml[55:9]: Detected anchors on an item that is managed by a layout. This is undefined behavior; use Layout.alignment instead.
            // anchors.verticalCenter: parent.verticalCenter
            // anchors.horizontalCenter: parent.horizontalCenter
            Components.Workspaces {
                bar: bar
            }
        }

        Item {
            Layout.fillWidth: true
        }

        RowLayout {
            id: rightSection
            spacing: 20
            Layout.alignment: Qt.AlignRight
            Layout.fillWidth: true

            Components.Tray {}
            StyledRect {
                id: statusIcons

                // anchors.left: parent.left
                // anchors.right: parent.right
                // anchors.bottom: power.top
                anchors.bottomMargin: Appearance.spacing.normal

                radius: Appearance.rounding.full
                // color: Colors.palette.m3surfaceContainer
                color: "white"

                implicitHeight: parent.implicitHeight
                implicitWidth: 300

                Components.StatusIcons {
                    id: statusIconsInner

                    anchors.centerIn: parent
                }
            }
            Components.Clock {}
            Components.Power {}
        }
    }
}

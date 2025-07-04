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

    function checkPopout(x) {
        const rsX = rightSection.x;
        const pad = statusIconsInner.spacing * 2;
        const stX = statusIcons.x;

        const iconStart = iconItem => rsX + stX + iconItem.x + pad;

        const trayStart = rsX + tray.x + pad;
        const trayEnd = trayStart + tray.implicitWidth;

        if (x >= trayStart && x < trayEnd) {
            const items = tray.items;
            const index = Math.floor(((x - trayStart) / tray.implicitWidth) * items.count);
            const item = items.itemAt(index);

            popouts.currentName = `traymenu${index}`;
            popouts.currentCenter = Qt.binding(() => trayStart + item.x + item.implicitWidth / 2);
            popouts.hasCurrent = true;
            return;
        }

        const icons = [
            {
                name: "bluetooth",
                item: statusIconsInner.bluetooth
            },
            {
                name: "network",
                item: statusIconsInner.network
            },
            {
                name: "battery",
                item: statusIconsInner.battery
            }
        ];

        for (let i = 0; i < icons.length; ++i) {
            const ic = icons[i];
            const start = iconStart(ic.item);
            const end = start + ic.item.implicitWidth;

            if (x >= start && x < end) {
                popouts.currentName = ic.name;
                const fixed = start;
                popouts.currentCenter = Qt.binding(() => fixed);
                popouts.hasCurrent = true;
                return;
            }
        }

        popouts.hasCurrent = false;
    }
    // function checkPopout(x: real): void {
    //     const rs = rightSection;
    //     const tr = tray;
    //     const st = statusIcons;
    //     const sp = statusIconsInner.spacing;
    //     const net = statusIconsInner.network;
    //     const bt = statusIconsInner.bluetooth;
    //     const bat = statusIconsInner.battery;

    //     const tr_area_start = rs.x + tr.x + sp * 2;
    //     const tr_area_end = tr_area_start + tr.implicitWidth;
    //     const trayItems = tray.items;

    //     const bt_area_start = rs.x + st.x + bt.x + sp * 2;
    //     const bt_area_end = bt_area_start + bt.implicitWidth;

    //     const net_area_start = rs.x + st.x + net.x + sp * 2;
    //     const net_area_end = net_area_start + net.implicitWidth;

    //     const bat_area_start = rs.x + st.x + bat.x + sp * 2;
    //     const bat_area_end = bat_area_start + bat.implicitWidth;

    //     if (x > tr_area_start && x < tr_area_end) {
    //         const index = Math.floor(((x - tr_area_start) / tr.implicitWidth) * trayItems.count);
    //         const item = trayItems.itemAt(index);

    //         popouts.currentName = `traymenu${index}`;
    //         popouts.currentCenter = Qt.binding(() => tr_area_start + item.x + item.implicitWidth / 2);
    //         popouts.hasCurrent = true;
    //     } else if (x > bt_area_start && x < bt_area_end) {
    //         popouts.currentName = "bluetooth";
    //         popouts.currentCenter = Qt.binding(() => bt_area_start);
    //         popouts.hasCurrent = true;
    //     } else if (x > net_area_start && x < net_area_end) {
    //         popouts.currentName = "network";
    //         popouts.currentCenter = Qt.binding(() => net_area_start);
    //         popouts.hasCurrent = true;
    //     } else if (x > bat_area_start && x < bat_area_end) {
    //         popouts.currentName = "battery";
    //         popouts.currentCenter = Qt.binding(() => bat_area_start);
    //         popouts.hasCurrent = true;
    //     } else {
    //         popouts.hasCurrent = false;
    //     }
    // // popouts.hasCurrent = hasCurrent;

    // // popouts.currentName = currentName;
    // // popouts.currentCenter = currentCenter;
    // }

    implicitHeight: Config.bar.sizes.innerHeight

    Rectangle {
        id: background
        anchors.fill: parent
        color: Colors.palette.m3background
    }

    RowLayout {
        id: content
        spacing: Appearance.padding.large

        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        anchors.centerIn: parent
        anchors.fill: parent
        anchors.leftMargin: Appearance.padding.large
        anchors.rightMargin: Appearance.padding.large

        RowLayout {
            id: leftSection
            spacing: Appearance.padding.large
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

            spacing: Appearance.padding.large
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
            spacing: Appearance.padding.large
            Layout.alignment: Qt.AlignRight
            Layout.fillWidth: true

            Components.Tray {
                id: tray
            }

            StyledRect {
                id: statusIcons

                radius: Appearance.rounding.full
                color: Colors.palette.m3surfaceContainer

                implicitHeight: parent.implicitHeight
                implicitWidth: statusIconsInner.implicitWidth

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

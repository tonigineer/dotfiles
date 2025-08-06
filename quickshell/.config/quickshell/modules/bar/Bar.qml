// qmllint disable missing-property

// import "../../common"
import "../../config"
import "../../services"
import "../../widgets"
import "../../modules/bar/popouts" as BarPopouts
import "components" as Components
import Quickshell
// import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Item {
    id: bar

    property ShellScreen modelData
    required property BarPopouts.Wrapper popouts

    function checkPopout(x) {
        // Left - OS overview
        const oiStart = leftSection.x + osicon.x;
        const oiEnd = leftSection.x + osicon.x + osicon.implicitWidth;

        if (x >= oiStart && x < oiEnd) {
            popouts.currentName = 'os-overview';
            popouts.currentCenter = Qt.binding(() => oiStart);
            popouts.hasCurrent = true;
            return;
        }

        // Right 1 - Screenshot button
        const start = rightSection.x + utilButtons.hyprshot.x;
        const end = rightSection.x + utilButtons.hyprshot.x + utilButtons.hyprshot.implicitWidth;
        if (x >= start && x < end) {
            const fixed = start + utilButtons.hyprshot.implicitWidth / 2;
            popouts.currentName = "screenshot";
            popouts.currentCenter = Qt.binding(() => fixed);
            popouts.hasCurrent = true;
            return;
        }

        // Right 2 - System tray
        const rsX = rightSection.x;
        const pad = statusIconsInner.spacing * 2 * 0; // disabled!
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

        // Right 3 - Icons
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
                const fixed = start + statusIconsInner.spacing;
                popouts.currentCenter = Qt.binding(() => fixed);
                popouts.hasCurrent = true;
                return;
            }
        }

        popouts.hasCurrent = false;
    }

    implicitHeight: Config.bar.sizes.innerHeight

    Rectangle {
        id: background
        anchors.fill: parent
        color: Colors.palette.m3background
    }

    Item {
        id: content
        anchors.fill: parent

        RowLayout {
            id: leftSection
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: Appearance.padding.large

            spacing: Appearance.padding.large

            Components.OsIcon {
                id: osicon
            }

            // TODO: Brightness and Audio scrolling somewhere else
            // monitor: Brightness.getMonitorForScreen(root.screen)
            Components.ActiveWindow {}

            Components.Media {
                id: media
            }
        }

        RowLayout {
            id: centerSection

            anchors.centerIn: parent

            spacing: Appearance.padding.large

            Components.Workspaces {
                id: workspaces
                bar: bar
            }
        }

        RowLayout {
            id: rightSection

            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: Appearance.padding.large

            spacing: Appearance.padding.large

            Components.UtilButtons {
                id: utilButtons
            }

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

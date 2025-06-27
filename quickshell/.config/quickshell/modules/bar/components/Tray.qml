import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray

import "root:/config"

Item {
    id: root

    required property var bar
    readonly property Repeater items: items

    clip: true
    visible: width > 0 && height > 0

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    RowLayout {
        id: layout

        spacing: Config.bar.widgetSpacing

        Repeater {
            id: items

            model: SystemTray.items

            TrayItem {
                bar: root.bar
            }
        }
    }
}

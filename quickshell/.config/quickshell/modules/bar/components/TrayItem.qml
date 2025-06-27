pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray

import "root:/config"

MouseArea {
    id: root
    required property var bar
    required property SystemTrayItem modelData

    acceptedButtons: Qt.LeftButton | Qt.RightButton
    implicitWidth: Config.bar.widgetIcon.iconSize
    implicitHeight: Config.bar.widgetIcon.iconSize

    onClicked: event => {
        switch (event.button) {
        case Qt.LeftButton:
            // modelData.activate();
            // ERROR:
            //  WARN quickshell.service.sni.item: Error calling Activate method of StatusNotifierItem :1.145/org/ayatana/NotificationItem/spotify_client/org.kde.StatusNotifierItem
            //  WARN quickshell.service.sni.item: QDBusError("org.freedesktop.DBus.Error.UnknownMethod", "No such method “Activate”")
            break;
        case Qt.RightButton:
            if (modelData.hasMenu)
                menu.open();
            break;
        }
        event.accepted = true;
    }

    QsMenuAnchor {
        id: menu

        menu: root.modelData.menu

        // TODO: handle menu anchor with anchor.window: this.QsWindow.window
        anchor.window: bar
        anchor.rect.x: root.x + bar.width
        anchor.rect.y: root.y
        anchor.rect.height: root.height * 1.5
        anchor.edges: Edges.Bottom
    }

    IconImage {
        id: icon

        source: {
            renderType: Text.NativeRendering;
            let icon = root.modelData.icon;
            if (icon.includes("?path=")) {
                const [name, path] = icon.split("?path=");
                icon = `file://${path}/${name.slice(name.lastIndexOf("/") + 1)}`;
            }
            return icon;
        }

        asynchronous: true
        anchors.fill: parent
    }
}

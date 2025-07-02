pragma ComponentBehavior: Bound

import "root:/widgets"
import "root:/config"
import "root:/services"
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import QtQuick

MouseArea {
    id: root

    required property SystemTrayItem modelData

    acceptedButtons: Qt.LeftButton | Qt.RightButton
    implicitWidth: Appearance.font.size.large
    implicitHeight: Appearance.font.size.large

    onClicked: event => {
        switch (event.button) {
        case Qt.LeftButton:
            // modelData.activate();
            Quickshell.execDetached(["kitty", "-c", "btop"]);
            break;
        case Qt.RightButton:
            if (modelData.hasMenu)
                menu.open();
            break;
        }
        event.accepted = true;
    }

    // TODO custom menu
    QsMenuAnchor {
        id: menu

        menu: root.modelData.menu
        anchor.window: this.QsWindow.window
    }

    IconImage {
        id: icon

        source: {
            let icon = root.modelData.icon;
            if (icon.includes("?path=")) {
                const [name, path] = icon.split("?path=");
                // icon = `file://${path}/${name.slice(name.lastIndexOf("/") + 1)}`;
                // console.log(name.slice(name.lastIndexOf("/") + 1));
                // icon = name.slice(name.lastIndexOf("/") + 1);
                icon = Quickshell.iconPath(AppSearch.guessIcon(name.slice(name.lastIndexOf("/") + 1)), "image-missing");
            }

            return icon;
        }
        asynchronous: true
        anchors.fill: parent
    }
}

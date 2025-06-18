import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import Quickshell.Hyprland

import "root:/common"
import "root:/config"
import "root:/modules"

Item {
    id: root
    required property var bar
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(bar.screen)
    readonly property Toplevel activeWindow: ToplevelManager.activeToplevel

    implicitWidth: colLayout.implicitWidth

    ColumnLayout {
        id: colLayout

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 0

        StyledText {
            Layout.fillWidth: true
            font.pixelSize: Vanity.font.pixelSize.smaller
            color: Vanity.color.activeWindow.app_id
            elide: Text.ElideRight
            text: root.activeWindow?.activated ? root.activeWindow?.appId : qsTr("Desktop")
        }

        StyledText {
            visible: Settings.bar.showActiveWindowTitle
            Layout.fillWidth: true
            font.pixelSize: Vanity.font.pixelSize.smallest
            color: Vanity.color.activeWindow.title
            elide: Text.ElideRight
            text: root.activeWindow?.activated ? root.activeWindow?.title : `${qsTr("Workspace")} ${monitor.activeWorkspace?.id}`
        }
    }
}

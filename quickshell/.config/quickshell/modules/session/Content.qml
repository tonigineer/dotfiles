pragma ComponentBehavior: Bound

import "root:/widgets"
import "root:/services"
import "root:/config"
import "root:/utils"
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import Qt.labs.platform

Column {
    id: root

    required property PersistentProperties visibilities

    padding: Appearance.padding.large

    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left

    spacing: Appearance.spacing.large

    SessionButton {
        id: logout

        icon: "logout"
        command: ["loginctl", "terminate-user", "$USER"]

        Keys.onPressed: ev => {
            if (ev.key === Qt.Key_K) {
                hibernate.forceActiveFocus();
                ev.accepted = true;
            }
            if (ev.key === Qt.Key_J) {
                shutdown.forceActiveFocus();
                ev.accepted = true;
            }
        }

        Connections {
            target: root.visibilities

            function onSessionChanged(): void {
                if (root.visibilities.session)
                    logout.focus = true;
            }

            function onLauncherChanged(): void {
                if (root.visibilities.session && !root.visibilities.launcher)
                    logout.focus = true;
            }
        }
    }

    SessionButton {
        id: hibernate

        icon: "autopause"
        command: ["systemctl", "suspend"]

        Keys.onPressed: ev => {
            if (ev.key === Qt.Key_K) {
                shutdown.forceActiveFocus();
                ev.accepted = true;
            }
            if (ev.key === Qt.Key_J) {
                reboot.forceActiveFocus();
                ev.accepted = true;
            }
        }
    }

    AnimatedImage {
        width: Config.session.sizes.button
        height: Config.session.sizes.button
        sourceSize.width: width
        sourceSize.height: height

        playing: visible
        asynchronous: true
        speed: 0.7
        source: Paths.expandTilde(Config.paths.sessionGif)
    }

    SessionButton {
        id: reboot

        icon: "cached"
        command: ["systemctl", "reboot"]

        Keys.onPressed: ev => {
            if (ev.key === Qt.Key_K) {
                hibernate.forceActiveFocus();
                ev.accepted = true;
            }
            if (ev.key === Qt.Key_J) {
                logout.forceActiveFocus();
                ev.accepted = true;
            }
        }
    }

    SessionButton {
        id: shutdown

        icon: "power_settings_new"
        command: ["systemctl", "poweroff"]

        Keys.onPressed: ev => {
            if (ev.key === Qt.Key_K) {
                logout.forceActiveFocus();
                ev.accepted = true;
            }
            if (ev.key === Qt.Key_J) {
                hibernate.forceActiveFocus();
                ev.accepted = true;
            }
        }
    }

    component SessionButton: StyledRect {
        id: button

        required property string icon
        required property list<string> command

        implicitWidth: Config.session.sizes.button
        implicitHeight: Config.session.sizes.button

        radius: Appearance.rounding.large
        color: button.activeFocus ? Colors.palette.m3secondaryContainer : Colors.palette.m3surfaceContainer

        Keys.onEnterPressed: Quickshell.execDetached(button.command)
        Keys.onReturnPressed: Quickshell.execDetached(button.command)
        Keys.onEscapePressed: root.visibilities.session = false

        StateLayer {
            radius: parent.radius
            color: button.activeFocus ? Colors.palette.m3onSecondaryContainer : Colors.palette.m3onSurface

            function onClicked(): void {
                // Quickshell.execDetached(button.command);
                Hyprland.dispatch("exec " + button.command.filter(x => x.length).join(" "));
            }
        }

        MaterialIcon {
            anchors.centerIn: parent

            text: button.icon
            color: button.activeFocus ? Colors.palette.m3onSecondaryContainer : Colors.palette.m3onSurface
            font.pointSize: Appearance.font.size.extraLarge
            font.weight: 500
        }
    }
}

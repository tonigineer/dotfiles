import QtQuick
import Quickshell
import Quickshell.Hyprland

import "bar" as B

Scope {
    id: root

    property ShellScreen screen

    B.Bar {
        screen: root.screen
    }
}

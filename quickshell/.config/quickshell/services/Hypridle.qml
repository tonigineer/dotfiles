pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root
    property bool active: false

    function update() {
        statusProc.running = true;
    }

    Component.onCompleted: update()  // QtQuick import is here needed, dont know why

    function toggle() {
        console.log("Hypridle toggle");
        Hyprland.dispatch("exec systemctl --user " + (root.active ? "stop" : "start") + " hypridle.service");
        root.active = !root.active;
    }

    Process {
        id: statusProc
        command: ["bash", "-c", "systemctl --user is-active hypridle.service"]
        stdout: StdioCollector {
            onStreamFinished: root.active = this.text.trim() === "active"
        }
    }
}

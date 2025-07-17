pragma Singleton
pragma ComponentBehavior: Bound

import "root:/widgets"
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property list<var> ddcMonitors: []
    readonly property list<Monitor> monitors: variants.instances

    function getMonitorForScreen(screen: ShellScreen): var {
        return monitors.find(m => m.modelData === screen);
    }

    property bool ddcCooldownActive: false

    Timer {
        id: ddcCooldownTimer
        interval: 250
        repeat: false
        running: false
        onTriggered: root.ddcCooldownActive = false
    }

    function increaseBrightness(): void {
        const focusedName = Hyprland.focusedMonitor.name;
        const monitor = monitors.find(m => focusedName === m.modelData.name);
        if (monitor)
            monitor.setBrightness(monitor.brightness + 0.1);
    }

    function decreaseBrightness(): void {
        const focusedName = Hyprland.focusedMonitor.name;
        const monitor = monitors.find(m => focusedName === m.modelData.name);
        if (monitor)
            monitor.setBrightness(monitor.brightness - 0.1);
    }

    reloadableId: "brightness"

    onMonitorsChanged: {
        ddcMonitors = [];
        ddcProc.running = true;
    }

    Variants {
        id: variants

        model: Quickshell.screens

        Monitor {}
    }

    Process {
        id: ddcProc
        command: ["ddcutil", "detect", "--brief"]

        stdout: SplitParser {
            splitMarker: "\n"
            property string buf: ""
            onRead: chunk => {
                buf += chunk + "\n";
                const monitors = buf.trim().split("\n\n").filter(b => b.startsWith("Display ")).map(b => ({
                            model: (b.match(/Monitor:.*:(.*):.*/) || [])[1] || "",
                            busNum: (b.match(/I2C bus:\s*\/dev\/i2c-([0-9]+)/) || [])[1] || ""
                        })).filter(m => m.model && m.busNum);
                if (monitors.length)
                    root.ddcMonitors = monitors;
            }
        }
    }

    // Process {
    //     id: ddcProc

    //     command: ["ddcutil", "detect", "--brief"]
    //     stdout: StdioCollector {
    //         onStreamFinished: root.ddcMonitors = text.trim().split("\n\n").filter(d => d.startsWith("Display ")).map(d => ({
    //                     model: d.match(/Monitor:.*:(.*):.*/)[1],
    //                     busNum: d.match(/I2C bus:[ ]*\/dev\/i2c-([0-9]+)/)[1]
    //                 }))
    //     }
    // }

    Process {
        id: setProc
    }

    CustomShortcut {
        name: "brightnessUp"
        description: "Increase brightness"
        onPressed: root.increaseBrightness()
    }

    CustomShortcut {
        name: "brightnessDown"
        description: "Decrease brightness"
        onPressed: root.decreaseBrightness()
    }

    component Monitor: QtObject {
        id: monitor

        required property ShellScreen modelData
        readonly property bool isDdc: root.ddcMonitors.some(m => m.model === modelData.model)
        readonly property string busNum: root.ddcMonitors.find(m => m.model === modelData.model)?.busNum ?? ""
        property real brightness

        readonly property Process initProc: Process {
            stdout: SplitParser {
                splitMarker: "\n"
                onRead: chunk => {
                    const [, , , current, max] = chunk.trim().split(" ");
                    if (current && max)
                        monitor.brightness = parseInt(current) / parseInt(max);
                }
            }
        }

        // readonly property Process initProc: Process {
        //     stdout: StdioCollector {
        //         onStreamFinished: {
        //             const [, , , current, max] = text.split(" ");
        //             monitor.brightness = parseInt(current) / parseInt(max);
        //         }
        //     }
        // }

        function setBrightness(value: real): void {
            value = Math.max(0, Math.min(1, value));
            const rounded = Math.round(value * 100);
            if (Math.round(brightness * 100) === rounded)
                return;

            brightness = value;

            if (isDdc && root.ddcCooldownActive) {
                return;
            }
            setProc.command = isDdc ? ["ddcutil", "-b", busNum, "setvcp", "10", rounded] : ["brightnessctl", "s", `${rounded}%`];
            setProc.startDetached();

            if (isDdc) {
                root.ddcCooldownActive = true;
                ddcCooldownTimer.restart();
            }
        }

        onBusNumChanged: {
            initProc.command = isDdc ? ["ddcutil", "-b", busNum, "getvcp", "10", "--brief"] : ["sh", "-c", `echo "a b c $(brightnessctl g) $(brightnessctl m)"`];
            initProc.running = true;
        }

        Component.onCompleted: {
            initProc.command = isDdc ? ["ddcutil", "-b", busNum, "getvcp", "10", "--brief"] : ["sh", "-c", `echo "a b c $(brightnessctl g) $(brightnessctl m)"`];
            initProc.running = true;
        }
    }
}

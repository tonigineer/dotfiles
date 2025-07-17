pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int updateInterval: 2000
    property bool powered: false
    property bool connected: false
    property bool discovering: false

    property bool scanEnabled: true
    property int scanTimeout: 5

    property var devices: []

    readonly property string materialSymbol: {
        if (!powered)
            return "bluetooth_disabled";
        if (discovering)
            return "bluetooth_searching";
        return "bluetooth";
    }

    Component.onCompleted: update()

    Timer {
        interval: root.updateInterval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: update()
    }

    function update() {
        infoPoll.startCheck();
        if (root.powered)
            connPoll.startCheck();
    }

    Process {
        id: infoPoll
        property string buffer: ""

        command: ["sh", "-c", "bluetoothctl show"]
        running: false

        stdout: SplitParser {
            onRead: data => infoPoll.buffer += data
        }

        function startCheck() {
            buffer = "";
            running = true;
        }

        onExited: {
            const p = /Powered:\s+(\w+)/i.exec(buffer);
            const d = /Discovering:\s+(\w+)/i.exec(buffer);
            root.powered = p && p[1] === "yes";
            root.discovering = d && d[1] === "yes";
        }
    }

    Process {
        id: connPoll
        property string buffer: ""
        property string scanPart: ""

        command: ["sh", "-c", "for mac in $(bluetoothctl devices | grep Device | awk '{print $2}'); do bluetoothctl info $mac; echo; done"]
        running: false

        stdout: SplitParser {
            onRead: data => connPoll.buffer += data + "\n"
        }

        function startCheck() {
            buffer = "";
            running = true;
        }

        onExited: {
            const devices = buffer.trim().split(/\n\n+/).map(block => ({
                        name: block.match(/Name:\s*(.*)/)?.[1] ?? "",
                        alias: block.match(/Alias:\s*(.*)/)?.[1] ?? "",
                        address: block.match(/Device\s+([0-9A-F:]{17})/i)?.[1] ?? "",
                        icon: block.match(/Icon:\s*(.*)/)?.[1] ?? "",
                        connected: /Connected:\s+yes/i.test(block),
                        paired: /Paired:\s+yes/i.test(block),
                        trusted: /Trusted:\s+yes/i.test(block)
                    })).filter(d => d.address && d.name);

            const list = root.devices;

            // remove objects that disappeared
            for (let i = list.length - 1; i >= 0; --i) {
                const obj = list[i];
                if (!devices.some(d => d.address === obj.address)) {
                    list.splice(i, 1)[0].destroy();
                }
            }

            // add missing ones or update existing
            devices.forEach(js => {
                const existing = list.find(o => o.address === js.address);
                if (existing) {
                    existing.lastIpcObject = js;
                } else {
                    list.push(deviceComp.createObject(root, {
                        lastIpcObject: js
                    }));
                }
            });

            root.devices = list;
        }
    }

    component Device: QtObject {
        required property var lastIpcObject
        readonly property string name: lastIpcObject.name
        readonly property string alias: lastIpcObject.alias
        readonly property string address: lastIpcObject.address
        readonly property string icon: lastIpcObject.icon
        readonly property bool connected: lastIpcObject.connected
        readonly property bool paired: lastIpcObject.paired
        readonly property bool trusted: lastIpcObject.trusted
    }

    Component {
        id: deviceComp

        Device {}
    }

    function toggleBluetooth() {
        const cmd = `bluetoothctl power ${powered ? "off" : "on"}`;

        Qt.createQmlObject(`
            import Quickshell.Io
            Process {
                command: ["sh", "-c", "${cmd.replace(/"/g, "\\\"")}"]
                running: true
                onExited: root.update()
            }
        `, root, "BtPowerToggle");
    }

    function startScanning() {
        const cmd = `bluetoothctl --timeout 10 scan on`;

        Qt.createQmlObject(`
            import Quickshell.Io
            Process {
                command: ["sh", "-c", "${cmd.replace(/"/g, "\\\"")}"]
                running: true
                onExited: root.update()
            }
        `, root, "BtScanStart");
    }
}

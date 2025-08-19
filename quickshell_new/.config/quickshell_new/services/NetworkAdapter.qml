pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    enum DeviceState {
        NotAvailable,
        Disconnected,
        Connected
    }

    property int updateInterval: 1000

    property int ethernetState: NetworkAdapter.DeviceState.NotAvailable
    property string ethernetDevice: ""
    property int wifiState: NetworkAdapter.DeviceState.NotAvailable
    property string wifiDevice: ""
    property var wifiAvailableNetworks: []
    property string wifiNetworkName: ""
    property int wifiNetworkStrength: 0

    property string materialSymbol: "signal_wifi_off"

    Component.onCompleted: refresh()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    function computeMaterialSymbol() {
        if (ethernetState === NetworkAdapter.DeviceState.Connected) {
            return "lan";
        }

        if (wifiState != NetworkAdapter.DeviceState.NotAvailable) {
            if (wifiState === NetworkAdapter.DeviceState.Disconnected)
                return "signal_wifi_statusbar_not_connected";

            const s = wifiNetworkStrength;
            if (s > 80)
                return "signal_wifi_4_bar";
            if (s > 60)
                return "network_wifi_3_bar";
            if (s > 40)
                return "network_wifi_2_bar";
            if (s > 20)
                return "network_wifi_1_bar";
        }

        return "signal_wifi_off";
    }

    function refresh() {
        updateConnectionType.startCheck();
        materialSymbol = computeMaterialSymbol();
        scanWifiNetworks.running = wifiState === NetworkAdapter.DeviceState.Disconnected;
    }

    function toggleWifi() {
        const cmd = `nmcli radio wifi ${root.wifiState === NetworkAdapter.DeviceState.NotAvailable ? "on" : "off"}`;

        Qt.createQmlObject(`
            import Quickshell.Io

            Process {
                command: ["sh", "-c", "${cmd}"]
                running: true

                onExited: root.refresh()
            }
        `, root, "WifiToggle");
    }

    function toggleEthernet() {
        if (!root.ethernetDevice) {
            console.warn("No Ethernet device detected");
            return;
        }

        const action = root.ethernetState === NetworkAdapter.DeviceState.Connected ? "disconnect" : "connect";
        Qt.createQmlObject(`
            import Quickshell.Io
            Process {
                command: ["nmcli", "device", "${action}", "${root.ethernetDevice}"]
                onExited: root.refresh()
                running: true
            }`, root, "EthToggle");
    }

    Process {
        id: updateConnectionType

        property string buffer
        command: ["sh", "-c", "nmcli -t -f TYPE,DEVICE,STATE device"]
        running: true

        function startCheck() {
            buffer = "";
            updateConnectionType.running = true;
        }
        stdout: SplitParser {
            onRead: data => {
                updateConnectionType.buffer += data + "\n";
            }
        }
        // qmllint disable signal-handler-parameters
        onExited: {
            buffer.trim().split('\n').forEach(line => {
                const [type, device, state] = line.trim().split(':');
                if (type === 'ethernet') {
                    root.ethernetDevice = device;
                    root.ethernetState = state === 'connected' ? NetworkAdapter.DeviceState.Connected : NetworkAdapter.DeviceState.Disconnected;
                }

                if (type === 'wifi') {
                    root.wifiDevice = device;
                    root.wifiState = state === 'connected' ? NetworkAdapter.DeviceState.Connected : (state === 'disconnected' ? NetworkAdapter.DeviceState.Disconnected : NetworkAdapter.DeviceState.NotAvailable);
                }
            });
        }
    }

    Process {
        id: scanWifiNetworks

        property string buffer: ""
        command: ["sh", "-c", "nmcli -t -f SSID,SIGNAL,SECURITY,ACTIVE,BSSID device wifi list"]

        stdout: SplitParser {
            onRead: data => scanWifiNetworks.buffer += data + "\n"
        }
        onExited: {
            const wifiAvailableNetworks = [];

            buffer.trim().split("\n").filter(line => line.length).forEach(line => {
                const [ssid, strength, security, active, ...bssidParts] = line.split(":");
                if (active === "yes") {
                    root.wifiNetworkStrength = strength;
                    root.wifiNetworkName = ssid;
                }

                if (ssid.length) {
                    wifiAvailableNetworks.push({
                        ssid: ssid,
                        bssid: bssidParts.map(part => part.replace(/\\/g, '')).join(':'),
                        strength: parseInt(strength),
                        state: active === "yes" ? NetworkAdapter.DeviceState.Connected : NetworkAdapter.DeviceState.Disconnected,
                        security: security.length ? security : "none"
                    });
                }
            });

            buffer = "";
            root.wifiAvailableNetworks = wifiAvailableNetworks.sort((a, b) => {
                if (a.state !== b.state)
                    return b.state - a.state;
                return b.strength - a.strength;
            });
        }
    }

    property real downloadMbps: 0
    property real uploadMbps: 0

    property real downloadMBs: downloadMbps / 8
    property real uploadMBs: uploadMbps / 8

    property int _prevRx: 0
    property int _prevTx: 0

    Timer {
        id: speedTimer
        interval: 1000
        repeat: true
        running: true
        onTriggered: {
            rxProc.restart();
            txProc.restart();
        }
    }

    Process {
        id: rxProc

        property int _rx: 0
        property int _prevRx: 0

        command: ["sh", "-c", "cat /sys/class/net/*/statistics/rx_bytes"]
        stdout: SplitParser {
            onRead: data => {
                data.trim().split('\n').forEach(line => {
                    const n = parseInt(line, 10);
                    if (!isNaN(n))
                        rxProc._rx += n;
                });
            }
        }

        function restart() {
            rxProc._rx = 0;
            running = true;
        }
        // qmllint disable missing-property
        onExited: {
            root.downloadMbps = Math.max((rxProc._rx - rxProc._prevRx) * 8 / (2 ** 20), 0);
            rxProc._prevRx = rxProc._rx;
        }
    }

    Process {
        id: txProc

        property int _tx: 0
        property int _prevTx: 0

        command: ["sh", "-c", "cat /sys/class/net/*/statistics/tx_bytes"]
        stdout: SplitParser {
            onRead: data => {
                data.trim().split('\n').forEach(line => {
                    const n = parseInt(line, 10);
                    if (!isNaN(n))
                        txProc._tx += n;
                });
            }
        }

        function restart() {
            txProc._tx = 0;
            running = true;
        }

        onExited: {
            root.uploadMbps = Math.max((txProc._tx - txProc._prevTx) * 8 / (2 ** 20), 0);
            txProc._prevTx = txProc._tx;
        }
    }
}

import Network from 'resource:///com/github/Aylur/ags/service/network.js';

import { NetworkManager } from "./../windows/network_manager";

// ALSO interesting method: https://github.com/kotontrion/dotfiles/blob/main/.config/ags/modules/network/speeds.js

enum Dir {
    tx,
    rx
}

const stats = {
    tx_bytes: [0, 0],
    tx_times: [0, 0],
    rx_bytes: [0, 0],
    rx_times: [0, 0],

    rate: function rate(this, dir: Dir): number {
        switch (dir) {
            case Dir.tx:
                return (this.tx_bytes[1] - this.tx_bytes[0]) / (this.tx_times[1] - this.tx_times[0]) / 1024;
            case Dir.rx:
                return (this.rx_bytes[1] - this.rx_bytes[0]) / (this.rx_times[1] - this.rx_times[0]) / 1024;
            default:
                console.log('Should never happen!');
                return 0;
        }
    }
}

Utils.interval(1000, () => {
    const adapter = Utils.exec(["bash", "-c", `nmcli | grep connected | head -n 1 | cut -d":" -f1`]);

    stats.rx_bytes[0] = stats.rx_bytes[1];
    stats.rx_bytes[1] = parseInt(Utils.exec([
        'bash',
        '-c',
        `cat /sys/class/net/${adapter}/statistics/rx_bytes`
    ]))

    stats.rx_times[0] = stats.rx_times[1];
    stats.rx_times[1] = Date.now();

    stats.tx_bytes[0] = stats.tx_bytes[1];
    stats.tx_bytes[1] = parseInt(Utils.exec([
        'bash',
        '-c',
        `cat /sys/class/net/${adapter}/statistics/tx_bytes`
    ]))

    stats.tx_times[0] = stats.tx_times[1];
    stats.tx_times[1] = Date.now();
})

const NetworkSpeeds = () => Widget.Box({
    class_name: "speeds",
    vertical: true,
    children: [
        Widget.Box({
            hpack: "end",
            children: [Widget.Label({
                class_name: "value",
                label: "0.0",
                setup: self => self.poll(1000, () => {
                    self.label = stats.rate(Dir.tx).toFixed(1);
                })
            }),
            Widget.Label({
                class_name: "icon",
                label: "",
                setup: self => self.poll(1000, () => {
                    self.class_name = stats.rate(Dir.tx) > 0.01 ? "icon tx" : "icon";
                })
            }),]
        }),
        Widget.Box({
            hpack: "end",
            children: [Widget.Label({
                class_name: "value",
                label: "0.0",
                setup: self => self.poll(1000, () => {
                    const rx = stats.rate(Dir.rx);
                    self.label = rx.toFixed(1);
                })
            }),
            Widget.Label({
                class_name: "icon",
                label: "",
                setup: self => self.poll(1000, () => {
                    self.class_name = stats.rate(Dir.rx) > 0.01 ? "icon rx" : "icon";
                })
            }),
            ]
        }),
    ]
})

const WifiIndicator = () => Widget.Box({
    class_name: "wifi",
    children: [Widget.Icon({ icon: Network.wifi.bind('icon_name') })],
})

const WiredIndicator = () => Widget.Box({
    class_name: "wired",
    children: [Widget.Icon({ icon: Network.wired.bind('icon_name') })]
})

const AdapterIndicator = () => Widget.Button({
    on_clicked: () => { NetworkManager.visible = !NetworkManager.visible; },
    child: Widget.Stack({
        class_name: "indicator",
        children: {
            wifi: WifiIndicator(),
            wired: WiredIndicator(),
        },
        shown: Network.bind('primary').as(p => p || 'wired'),
    })
})

export const NetworkIndicator = () => Widget.Box({
    spacing: 10,
    class_name: "network",
    children: [
        NetworkSpeeds(),
        AdapterIndicator()
    ],
})
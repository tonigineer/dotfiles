import { NETWORK } from "./../index";
import { NetworkManager } from "./../windows/network";


const tx = {
    bytes: 0,
    time: Date.now(),
    megabytes_per_second: 0
}

const rx = {
    bytes: 0,
    time: Date.now(),
    megabytes_per_second: 0
}

const adapterName = Variable("", {
    poll: [
        2000,
        ["bash", "-c", `ip route | grep default | awk '{print $5}' | head -n 1`],
        out => out
    ]
})

Utils.interval(2000, () => Utils.execAsync(['bash', '-c', `cat /sys/class/net/${adapterName.value}/statistics/rx_bytes`])
    .then((output) => {
        let bytes = parseInt(output);
        let time = Date.now();
        rx.megabytes_per_second = ((bytes - rx.bytes) / (time - rx.time) / 1024);
        rx.bytes = bytes;
        rx.time = time;
    }).catch((output) => { }))

Utils.interval(2000, () => Utils.execAsync(['bash', '-c', `cat /sys/class/net/${adapterName.value}/statistics/tx_bytes`])
    .then((output) => {
        let bytes = parseInt(output);
        let time = Date.now();
        tx.megabytes_per_second = ((bytes - tx.bytes) / (time - tx.time) / 1024);
        tx.bytes = bytes;
        tx.time = time;
    }).catch((output) => { }))

const WifiIndicator = () => Widget.Box({
    // class_name: "network",
    children: [
        Widget.Icon({
            icon: NETWORK.wifi.bind('icon_name'),
        }),
        // Widget.Label({
        //     label: NETWORK.wifi.bind('ssid')
        //         .as(ssid => ssid || 'Unknown'),
        // }),
    ],
})

const WiredIndicator = () => Widget.Icon({
    // class_name: "network",
    icon: NETWORK.wired.bind('icon_name'),
})

const AdapterIndicator = () => Widget.Button({
    on_clicked: () => { NetworkManager.visible = !NetworkManager.visible; },
    child: Widget.Stack({
        class_name: "network icon",
        children: {
            wifi: WifiIndicator(),
            wired: WiredIndicator(),
        },
        shown: NETWORK.bind('primary').as(p => p || 'wifi'),
    })
})

const NetworkIndicator = () => Widget.Box({
    class_name: "network",
    children: [
        Widget.Box({
            class_name: "network rates",
            vertical: true,
            children: [
                Widget.Box({
                    hpack: "end",
                    children: [
                        Widget.Label({ label: "0" }),
                        Widget.Label({ label: "󰦘" }),
                    ]
                }),
                Widget.Box({
                    hpack: "end",
                    children: [
                        Widget.Label({ label: "0" }),
                        Widget.Label({ label: "󰦗" }),
                    ]
                }),
            ],
        }),
        AdapterIndicator(),
    ],
    setup: self => self.poll(1000, () => {
        const tx_label = self.children[0].children[0].children[0];
        const rx_label = self.children[0].children[1].children[0];
        tx_label.label = tx.megabytes_per_second.toFixed(1);
        tx_label.class_name = tx.megabytes_per_second >= 0.1 ? "network rates active" : "network rates";
        rx_label.label = rx.megabytes_per_second.toFixed(1);
        rx_label.class_name = rx.megabytes_per_second >= 0.1 ? "network rates active" : "network rates";
    })
})

export { NetworkIndicator }
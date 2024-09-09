import { NETWORK } from "./../index";


const wiredConnection = Widget.Box({
    spacing: 100,
    homogeneous: false,
    vertical: false,
    children: [
        Widget.Label({
            label: "Ethernet",
        }),
        Widget.Button({
            label: "On/Off",
        })
    ]
})

const wifiConnection = Widget.Box({
    spacing: 100,
    homogeneous: false,
    vertical: false,
    children: [
        Widget.Label({
            label: "Ethernet",
        }),
        Widget.Button({
            label: "On/Off",
            setup: self => self.hook(NETWORK, () => { })
        })
    ]
})

setup: self => self.poll(1000, () => {
    const tx_label = self.children[0].children[0].children[0];
    const rx_label = self.children[0].children[1].children[0];
    tx_label.label = tx.megabytes_per_second.toFixed(1);
    tx_label.class_name = tx.megabytes_per_second >= 0.1 ? "network rates active" : "network rates";
    rx_label.label = rx.megabytes_per_second.toFixed(1);
    rx_label.class_name = rx.megabytes_per_second >= 0.1 ? "network rates active" : "network rates";
})



const NetworkManager = Widget.Window({
    class_name: "networkmanager",
    name: "network-manager",
    child: Widget.Box({
        spacing: 10,
        vertical: true,
        children: [
            Widget.Separator({
                vertical: true,
                css: "min-height: 1rem;"
            }),
            wiredConnection,
            Widget.Separator({
                vertical: true,
                css: "min-height: 1rem;"
            }),
            wifiConnection,
            Widget.Separator({
                vertical: true,
                css: "min-height: 1rem;"
            }),
        ]
    }),
    visible: true,
    anchor: ["top", "right"],
    layer: "overlay",
    margins: [0, 50],
});

export { NetworkManager };
import Network from 'resource:///com/github/Aylur/ags/service/network.js';


function NetworkControl() {
    const Buttons = () => Widget.Box({
        class_name: "header",
        children: [
            Widget.Box({
                class_name: "combination-button active",
                children: [
                    Widget.Button({
                        class_name: "icon",
                        on_clicked: () => {
                            Utils.execAsync(
                                ["bash", "-c",
                                    `nmcli device ${Network.wired.state !== "activated"
                                        ? "connect"
                                        : "disconnect"} $(nmcli device | grep ethernet | cut -d" " -f1)`]
                            );
                        },
                        on_secondary_click: () => { Utils.execAsync(`kitty --title float -e nmtui`) },
                        child: Widget.Icon({
                            icon: Network.wired.bind('icon_name'),
                        }).hook(Network, self => {
                            self.icon_name = Network.wired.icon_name;
                        }, "changed")
                    }),
                    Widget.Button({
                        class_name: "opener",
                        on_clicked: (self) => {
                            WiredInfos.reveal_child = !WiredInfos.reveal_child;
                            self.child.icon_name = `button-arrow-${WiredInfos.child_revealed ? "down" : "up"}-symbolic`;
                        },
                        child: Widget.Icon("button-arrow-down-symbolic"),
                    }),
                ]
            }).hook(Network, self => {
                self.class_name = `combination-button${Network.wired.state === "activated" ? " active" : ""
                    }`
            }, "changed"),
            Widget.Box({ hexpand: true }),
            Widget.Box({
                class_name: "combination-button active",
                children: [
                    Widget.Button({
                        class_name: "icon",
                        // on_clicked: () => { Network.toggleWifi() },  DOES NOT WORK, AGS CRASHES
                        on_clicked: () => {
                            Utils.execAsync(["bash", "-c",
                                `nmcli device ${Network.wifi.state !== "activated" ? "connect" : "disconnect"} $(nmcli device | grep 'wifi ' | cut -d" " -f1)`
                            ])
                        },
                        on_secondary_click: () => { Utils.execAsync(`kitty --title float -e nmtui`) },
                        child: Widget.Icon({
                            icon: Network.wifi.bind('icon_name'),
                        }).hook(Network, self => {
                            self.icon_name = Network.wifi.icon_name;
                            // console.log(Network.wifi.icon_name);
                        }, "changed")
                    }),
                    Widget.Button({
                        class_name: "opener",
                        on_clicked: (self) => {
                            WifiInfos.reveal_child = !WifiInfos.reveal_child;
                            self.child.icon_name = `button-arrow-${WifiInfos.child_revealed ? "down" : "up"}-symbolic`;
                        },
                        child: Widget.Icon("button-arrow-down-symbolic"),
                    }),
                ]
            }).hook(Network, self => {
                self.class_name = `combination-button${Network.wifi.state === "activated" ? " active" : ""
                    }`;
                if (Network.wifi.state !== "activated") WifiInfos.reveal_child = false;
            }, "changed"),
        ]
    })

    const WiredInfos = Widget.Revealer({
        reveal_child: false,
        child: Widget.Box({
            class_name: "infos",
            vertical: true,
            children: [
                Widget.Box({
                    class_name: "wired",
                    children: [
                        Widget.Label("Connectivity"),
                        Widget.Box({ hexpand: true }),
                        Widget.Label({
                            class_name: "value",
                            css: "font-weight: bold; color: lightgreen;",
                            label: Network.bind("connectivity")
                        }),
                    ]
                }),
                Widget.Box({
                    children: [
                        Widget.Label({
                            class_name: "label",
                            label: "IP Address",
                        }),
                        Widget.Box({ hexpand: true }),
                        Widget.Label({
                            class_name: "value",
                            label: Network.bind("primary").as(_v => {
                                return Utils.exec(["bash", "-c", `nmcli | grep inet4 | head -n 1 | cut -d" " -f2 | cut -d"/" -f1`]);
                            })
                        }),
                    ]
                }),
                Widget.Box({
                    children: [
                        Widget.Label({
                            class_name: "label",
                            label: "Gateway",
                        }),
                        Widget.Box({ hexpand: true }),
                        Widget.Label({
                            css: "color: grey;",
                            label: Network.bind("primary").as(_v => {
                                return Utils.exec(["bash", "-c", `nmcli | grep 'route4 default via' | head -n 1 | cut -d" " -f4`]);
                            })
                        }),
                    ]
                }),
            ]
        })
    })

    const WifiInfos = Widget.Revealer({
        reveal_child: false,
        child: Widget.Box({
            class_name: "infos",
            vertical: true,
            children: [
                Widget.Box({
                    class_name: "wifi",
                    children: [
                        Widget.Label({
                            class_name: "label",
                            label: "WI-FI",
                        }),
                        Widget.Box({ hexpand: true }),
                        Widget.Label({
                            css: "font-weight: bold; color: lightgreen;",
                            label: Network.wifi.bind("state"),
                        }),
                    ]
                }),
                Widget.Box({
                    children: [
                        Widget.Label("SSID"),
                        Widget.Box({ hexpand: true }),
                        Widget.Label({
                            class_name: "value",

                            label: Network.wifi.bind("ssid").as(out => `${out}`),
                        }),
                    ]
                }),
                Widget.Box({
                    children: [
                        Widget.Label({
                            class_name: "label",
                            label: "Signal strength",
                        }),
                        Widget.Box({ hexpand: true }),
                        Widget.Label({
                            class_name: "value",
                            label: Network.wifi.bind("strength").as(out => `${out} `),
                        }),
                    ]
                }),
                Widget.Box({
                    children: [
                        Widget.Label({
                            class_name: "label",
                            label: "Frequency",
                        }),
                        Widget.Box({ hexpand: true }),
                        Widget.Label({
                            css: "color: grey;",
                            label: Network.wifi.bind("frequency").as(out => `${out} MHz`),
                        }),
                    ]
                }),
            ]
        })
    })


    return Widget.Box({
        class_name: "network-control",
        vertical: true,
        children: [
            Widget.Box({
                children: [
                    Buttons()
                ]
            }),
            Widget.Box({
                vertical: true,
                children: [
                    WiredInfos,
                    WifiInfos
                ]
            })
        ]
    })
}

export default NetworkControl;
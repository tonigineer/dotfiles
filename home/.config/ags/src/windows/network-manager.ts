// import { NETWORK } from "./../index";
import Network from 'resource:///com/github/Aylur/ags/service/network.js';


const connectivity = Widget.CenterBox({
    spacing: 20,
    startWidget: Widget.Label({
        class_name: "label",
        hpack: "start",
        label: "Connectivity",
    }),
    centerWidget: Widget.Label({
        label: Network.bind("connectivity").as(v => {
            connectivity.center_widget.class_name = `${v}`;
            return `${v.toUpperCase()}`;
        })
    }),
    endWidget: Widget.Label({
        class_name: "value",
        hpack: "end",
        label: Network.bind("primary").as(v => `${v?.toUpperCase()}`)
    })
})

const ipAddress = Widget.CenterBox({
    spacing: 20,
    startWidget: Widget.Label({
        class_name: "label",
        hpack: "start",
        label: "IP Address"
    }),
    endWidget: Widget.Label({
        class_name: "value",
        hpack: "end",
        label: Network.bind("primary").as(_v => {
            return Utils.exec(["bash", "-c", `nmcli | grep inet4 | head -n 1 | cut -d" " -f2 | cut -d"/" -f1`]);
        })
    })
})

const gateway = Widget.CenterBox({
    spacing: 20,
    startWidget: Widget.Label({
        class_name: "label",
        hpack: "start",
        label: "Gateway"
    }),
    endWidget: Widget.Label({
        class_name: "value",
        hpack: "end",
        label: Network.bind("primary").as(_v => {
            return Utils.exec(["bash", "-c", `nmcli | grep 'route4 default via' | head -n 1 | cut -d" " -f4`]);
        })
    })
})

const panelHeader = Widget.Box({
    spacing: 5,
    class_name: "header",
    vertical: true,
    children: [
        connectivity,
        ipAddress,
        gateway
    ]
})

const wiredControl = Widget.CenterBox({
    class_name: "control",
    spacing: 150,
    startWidget: Widget.Label({ class_name: "label", label: "Ethernet", }),
    endWidget: Widget.Switch({
        active: Network.wired.state === "activated"
    }).on("notify::active", ({ active }) => {
        wiredInfos.reveal_child = active;
        Utils.execAsync([
            "bash",
            "-c",
            `nmcli device ${active ? "connect" : "disconnect"} $(nmcli device | grep ethernet | cut -d" " -f1)`
        ]);
    }),
})

const wiredInfos = Widget.Revealer({
    revealChild: Network.wired.bind("state").as(v => v === "activated"),
    transitionDuration: 500,
    transition: 'slide_down',
    child: Widget.Box({
        spacing: 3,
        class_name: "infos",
        vertical: true,
        visible: false,
        children: [
            Widget.CenterBox({
                startWidget: Widget.Label({
                    class_name: "label",
                    label: "Speed",
                    hpack: "start"
                }),
                endWidget: Widget.Label({
                    class_name: "value",
                    label: Network.wired.bind("speed").as(out => `${out} Mbit/s`),
                    hpack: "end"
                })

            }),
            Widget.CenterBox({
                startWidget: Widget.Label({
                    class_name: "label",
                    label: "State",
                    hpack: "start"
                }),
                endWidget: Widget.Label({
                    class_name: "value",
                    label: Network.wired.bind("state"), hpack: "end"
                })
            }),
        ]
    })
})

const wiredPanel = Widget.Box({
    class_name: "wired",
    vertical: true,
    children: [
        wiredControl,
        wiredInfos,
    ]
})

const wifiControl = Widget.CenterBox({
    class_name: "control",
    spacing: 150,
    startWidget: Widget.Label({ class_name: "label", label: "Wireless", }),
    endWidget: Widget.Switch({
        active: Network.wifi.state === "activated"
    }).on("notify::active", ({ active }) => {
        wifiInfos.reveal_child = active;
        Utils.execAsync([
            "bash",
            "-c",
            `nmcli device ${active ? "connect" : "disconnect"} $(nmcli device | grep 'wifi ' | cut -d" " -f1)`
        ])
    })
})


// Widget.ToggleButton({
//     label: Network.wifi.bind("state").as(v => v === "activated" ? "󰔡 " : "󰨚 "),
//     class_name: Network.wifi.state === "activated" ? "on" : "off",
//     onToggled: ({ active }) => {
//         const widget = wifiControl.end_widget;  // TODO works, but self should be given via onToggled, but how???
//         widget.label = active ? "󰔡 " : "󰨚 ";
//         widget.class_name = active ? "on" : "off";
//         wifiInfos.reveal_child = active;
//         Utils.execAsync(["bash", "-c", `nmcli device ${active ? "connect" : "disconnect"} $(nmcli device | grep 'wifi ' | cut -d" " -f1)`]);
//     },
// }),
// })

const wifiInfos = Widget.Revealer({
    revealChild: Network.wifi.bind("state").as(v => v === "activated"),
    transitionDuration: 500,
    transition: 'slide_down',
    child: Widget.Box({
        spacing: 3,
        class_name: "infos",
        vertical: true,
        visible: false,
        children: [
            Widget.CenterBox({
                startWidget: Widget.Label({
                    class_name: "label",
                    label: "SSID",
                    hpack: "start"
                }),
                endWidget: Widget.Label({
                    class_name: "value",
                    label: Network.wifi.bind("ssid").as(out => `${out}`),
                    hpack: "end"
                })
            }),
            Widget.CenterBox({
                startWidget: Widget.Label({
                    class_name: "label",
                    label: "Signal strength",
                    hpack: "start"
                }),
                endWidget: Widget.Label({
                    class_name: "value",
                    label: Network.wifi.bind("strength").as(out => `${out} `),
                    hpack: "end"
                })
            }),
            Widget.CenterBox({
                startWidget: Widget.Label({
                    class_name: "label",
                    label: "Frequency",
                    hpack: "start"
                }),
                endWidget: Widget.Label({
                    class_name: "value",
                    label: Network.wifi.bind("frequency").as(out => `${out} MHz`),
                    hpack: "end"
                })
            }),
            Widget.CenterBox({
                startWidget: Widget.Label({
                    class_name: "label",
                    label: "State",
                    hpack: "start"
                }),
                endWidget: Widget.Label({
                    class_name: "value",
                    label: Network.wifi.bind("state"), hpack: "end"
                })
            }),
        ]
    })
})

const wifiPanel = Widget.Box({
    class_name: "wired",
    vertical: true,
    children: [
        wifiControl,
        wifiInfos,
    ]
})

const NetworkManager = Widget.Window({
    class_name: "networkmanager",
    name: "network-manager",
    child: Widget.ListBox({
        setup(self) {
            self.add(panelHeader);
            Network.wired?.state != "unknown" ? self.add(wiredPanel) : null;
            Network.wifi?.state != "unknown" ? self.add(wifiPanel) : null;
        },
    }),
    visible: false,
    anchor: ["top", "right"],
    layer: "overlay",
    margins: [15, 15],
});

export default NetworkManager;
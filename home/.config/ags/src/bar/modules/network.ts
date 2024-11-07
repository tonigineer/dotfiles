import Network from 'resource:///com/github/Aylur/ags/service/network.js';
import NetworkSpeed from "./../../services/network";


// App.addIcons(`${App.configDir}/assets`)

const NetworkSpeeds = () => Widget.Box({
    class_name: "speeds",
    vertical: true,
    children: [
        Widget.Box({
            hpack: "end",
            children: [
                // Widget.Label({
                //     class_name: "value",
                //     label: NetworkSpeed.bind("speed")
                //         .as(speed => `${(speed.upBytes / 1024 / 1000).toFixed(1)}`),
                // }),
                Widget.Label({
                    class_name: NetworkSpeed.bind("speed")
                        .as(speed => speed.upBytes > 1000 ? "icon tx" : "icon"),
                    label: "",
                }),
            ]
        }),
        Widget.Box({
            css: "margin-top: -0.15rem;",  // nasty bu necessary to squeeze it
            hpack: "end",
            children: [
                // Widget.Label({
                //     class_name: "value",
                //     label: NetworkSpeed.bind("speed")
                //         .as(speed => `${(speed.downBytes / 1024 / 1000).toFixed(1)}`),
                // }),
                Widget.Label({
                    class_name: NetworkSpeed.bind("speed")
                        .as(speed => speed.downBytes > 1000 ? "icon rx" : "icon"),
                    label: "",

                }),
            ]
        }),
    ]
})

function adapter_tooltip(): string {
    const down_speed = NetworkSpeed.speed.downBytes;
    return `Connectivity \t\t ${Network.connectivity}
IP-Address \t\t\t ${Utils.exec(["bash", "-c", `nmcli | grep inet4 | head -n 1 | cut -d" " -f2 | cut -d"/" -f1`])}
${Network.primary === "wifi" ? "Signal strength \t " + Network.wifi.strength + " " : "Network speed \t\t " + Network.wired.speed + " MBit\\s"}

Download \t\t\t ${(NetworkSpeed.speed.downBytes / 1024 / 1000).toFixed(1)} Mb
Upload \t\t\t\t ${(NetworkSpeed.speed.upBytes / 1024 / 1000).toFixed(1)} Mb

 Toggle Settings Sidebar  `
}

const AdapterIndicator = () => Widget.Button({
    on_clicked: () => { App.toggleWindow("SidebarSettings"); },
    child: Widget.Stack({
        class_name: "indicator",
        children: {
            wifi: Widget.Box({
                class_name: "wifi",
                child: Widget.Icon({
                    css: "margin-left: 0.5rem;",
                    size: 20
                }).hook(Network, self => { self.icon_name = Network.wifi.icon_name.replace("symbolic", "custom-symbolic"); }, "changed"),
            }),
            wired: Widget.Box({
                class_name: "wired",
                child: Widget.Icon({
                    css: "margin-left: 0.5rem;",
                    icon: Network.wired.bind('icon_name'),
                    size: 17
                }).hook(Network, self => { self.icon_name = Network.wired.icon_name; }, "changed")
            }),
        },
        shown: Network.bind('primary').as(p => p || "wifi"),
    }).hook(NetworkSpeed, self => { self.tooltip_text = adapter_tooltip() }, "changed")
})

const NetworkIndicator = () => Widget.Box({
    class_name: "network",
    children: [
        NetworkSpeeds(),
        AdapterIndicator()
    ],
})

export default NetworkIndicator;
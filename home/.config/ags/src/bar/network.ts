import Network from 'resource:///com/github/Aylur/ags/service/network.js';
import NetworkSpeed from "./../services/network";


const NetworkSpeeds = () => Widget.Box({
    class_name: "speeds",
    vertical: true,
    children: [
        Widget.Box({
            hpack: "end",
            children: [Widget.Label({
                class_name: "value",
                label: NetworkSpeed.bind("speed")
                    .as(speed => `${(speed.upBytes / 1024 / 1000).toFixed(1)}`),
            }),
            Widget.Label({
                class_name: NetworkSpeed.bind("speed")
                    .as(speed => speed.upBytes > 1000 ? "icon tx" : "icon"),
                label: "",
            }),]
        }),
        Widget.Box({
            css: "margin-top: -0.25rem;",  // nasty bu necessary to squeeze it
            hpack: "end",
            children: [Widget.Label({
                class_name: "value",
                label: NetworkSpeed.bind("speed")
                    .as(speed => `${(speed.downBytes / 1024 / 1000).toFixed(1)}`),
            }),
            Widget.Label({
                class_name: NetworkSpeed.bind("speed")
                    .as(speed => speed.downBytes > 1000 ? "icon rx" : "icon"),
                label: "",

            }),
            ]
        }),
    ]
})

const AdapterIndicator = () => Widget.Button({
    on_clicked: () => { App.toggleWindow("network-manager") },
    child: Widget.Stack({
        class_name: "indicator",
        children: {
            wifi: Widget.Box({
                class_name: "wifi",
                children: [Widget.Icon({ icon: Network.wifi.bind('icon_name') })],
            }),
            wired: Widget.Box({
                class_name: "wired",
                children: [Widget.Icon({ icon: Network.wired.bind('icon_name') })]
            }),
        },
        shown: Network.bind('primary').as(p => p || 'wired'),
    })
})

const NetworkIndicator = () => Widget.Box({
    class_name: "network",
    children: [
        NetworkSpeeds(),
        AdapterIndicator()
    ],
})

export default NetworkIndicator;
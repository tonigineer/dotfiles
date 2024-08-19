const hyprland = await Service.import("hyprland");

function ClientTitle() {
    return Widget.Label({
        class_name: "client-title",
        label: hyprland.active.client.bind("title"),
    })
}



function Bar(monitor = 1) {
    // const mode = monitor.name === "DP-2" ? "collapsed" : "full";
    // const disableHover = monitor.name !== "DP-2";
    return Widget.Window({
        name: `bar-${monitor}`,
        class_name: "bar",
        monitor: monitor,
        anchor: ["top", "left", "right"],
        exclusivity: "exclusive",
        child: Widget.CenterBox({
            start_widget: Widget.Box({
                hpack: "start",
                className: "right",
                children: [ClientTitle()]
            }),
            center_widget: Widget.Box({
                hpack: "center",
                className: "right",
                children: [ClientTitle()]
            }),
            end_widget: Widget.Box({
                hpack: "end",
                className: "right",
                children: [ClientTitle()]
            }),
        }),
    })
}
// });


export default {
    windows: hyprland.monitors.map((m) => Bar(m.id)),
};

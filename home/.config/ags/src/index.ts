export const HYPRLAND = await Service.import("hyprland")

// Widgets left side
import { ClientTitle } from "./widgets/client";

// Widgets center
import { Workspaces } from "./widgets/workspaces";

// Widgets right side
import { SystemTray } from "./widgets/system_tray";
import { Clock } from "./widgets/clock";
import { ShutdownMenu } from "./widgets/shutdown_menu";

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
                children: [Workspaces()]
            }),
            end_widget: Widget.Box({
                hpack: "end",
                className: "right",
                children: [
                    SystemTray(),
                    Clock(),
                    ShutdownMenu(),
                ]
            }),
        }),
    })
}

export default {
    windows: HYPRLAND.monitors.map((m) => Bar(m.id)),
};
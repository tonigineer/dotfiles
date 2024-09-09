export const HYPRLAND = await Service.import("hyprland")
export const NETWORK = await Service.import('network')

// Widgets left side
import { ArchIcon } from "./widgets/launcher";
import { ResourceMonitor } from "./widgets/resources";
import { UpdateIndicator } from "./widgets/updates";
import { ClientTitle } from "./widgets/client";

// Widgets center
import { Workspaces } from "./widgets/workspaces";

// Widgets right side
import { NetworkIndicator } from "./widgets/network";
import { SystemTray } from "./widgets/system_tray";
import { Clock } from "./widgets/clock";
import { ShutdownMenu } from "./widgets/shutdown";

const Bar = async (monitor = 0) => {
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
                className: "left widgets spacing",
                children: [
                    ArchIcon(),
                    ResourceMonitor(),
                    ClientTitle(),
                    UpdateIndicator(),
                ]
            }),
            center_widget: Widget.Box({
                hpack: "center",
                className: "right",
                children: [Workspaces()]
            }),
            end_widget: Widget.Box({
                hpack: "end",
                className: "right widgets spacing",
                children: [
                    SystemTray(),
                    NetworkIndicator(),
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
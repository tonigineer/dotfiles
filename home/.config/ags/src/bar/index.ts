import type { Monitor } from "types/service/hyprland";

import ArchIcon from "./modules/launcher";
import Battery from "./modules/battery";
import ClientTitle from "./modules/client";
import Clock from "./modules/clock";
import NetworkIndicator from "./modules/network";
import ResourceMonitor from "./modules/resources";
import SystemTray from "./modules/system-tray";
import UpdateIndicator from "./modules/updates";
import Workspaces from "./modules/workspaces";


const Bar = async (monitor: Monitor) => {
    return Widget.Window({
        name: `bar-${monitor.id}`,
        monitor: monitor.id,
        anchor: ["top", "left", "right"],
        exclusivity: "exclusive",
        margins: [5, 7.5, 2.5, 7.5],
        child: Widget.CenterBox({
            class_name: "bar",
            start_widget: Widget.Box({
                hpack: "start",
                children: [
                    ArchIcon(),
                    ResourceMonitor(),
                    UpdateIndicator(),
                    // ClientTitle(),
                ]
            }),
            center_widget: Widget.Box({
                hpack: "center",
                child: Workspaces(monitor)
            }),
            end_widget: Widget.Box({
                hpack: "end",
                children: [
                    SystemTray(),
                    NetworkIndicator(),
                    Battery(),
                    Clock(),
                ]
            })
        })
    })
}

export default Bar;
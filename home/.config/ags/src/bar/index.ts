import ArchIcon from "./launcher";
import ClientTitle from "./client";
import ResourceMonitor from "./resources";
import UpdateIndicator from "./updates";

import Workspaces from "./workspaces";

import AudioIndicator from "./audio";
import BluetoothIndicator from "./bluetooth";
import Clock from "./clock";
import NetworkIndicator from "./network";
import SettingsBox from "./settings";
import ShutdownMenu from "./shutdown";
import SystemTray from "./system-tray";

import type { Monitor } from "types/service/hyprland";


const Bar = async (monitor: Monitor) => {
    // const mode = monitor.name === "DP-2" ? "collapsed" : "full";
    // const disableHover = monitor.name !== "DP-2";

    return Widget.Window({
        name: `bar-${monitor.id}`,
        class_name: "bar",
        monitor: monitor.id,
        anchor: ["top", "left", "right"],
        exclusivity: "exclusive",
        child: Widget.CenterBox({
            start_widget: Widget.Box({
                hpack: "start",
                className: "left widgets spacing",
                children: [
                    ArchIcon(),
                    ResourceMonitor(),
                    UpdateIndicator(),
                    ClientTitle(),
                ]
            }),
            center_widget: Widget.Box({
                hpack: "center",
                className: "center",
                children: [Workspaces(monitor)]
            }),
            end_widget: Widget.Box({
                hpack: "end",
                className: "right widgets spacing",
                children: [
                    NetworkIndicator(),
                    AudioIndicator(),
                    SystemTray(),
                    SettingsBox(),
                    BluetoothIndicator(),
                    Clock(),
                    ShutdownMenu(),
                ]
            }),
        }),
    })
}

export default Bar;
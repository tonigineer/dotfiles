import ArchIcon from "./launcher";
import ClientTitle from "./client";
import ResourceMonitor from "./resources";
import UpdateIndicator from "./updates";
import Media from "./media";

import Workspaces from "./workspaces";

import AudioIndicator from "./audio";
import BatteryIndicator from "./power";
import BluetoothIndicator from "./bluetooth";
import Clock from "./clock";
import NetworkIndicator from "./network";
import SettingsBox from "./settings";
import ShutdownMenu from "./shutdown";
import SystemTray from "./system-tray";

import type { Monitor } from "types/service/hyprland";


const Bar = async (monitor: Monitor) => {
    return Widget.Window({
        name: `bar-${monitor.id}`,
        monitor: monitor.id,
        anchor: ["top", "left", "right"],
        exclusivity: "exclusive",
        child: Widget.CenterBox({
            class_name: "bar",
            start_widget: Widget.Box({
                hpack: "start",
                children: [
                    ArchIcon(),
                    ResourceMonitor(),
                    UpdateIndicator(),
                    ClientTitle(),
                    // Media()
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
                    SettingsBox(),
                    BluetoothIndicator(),
                    AudioIndicator(),
                    NetworkIndicator(),
                    BatteryIndicator(),
                    Clock(),
                    ShutdownMenu(),
                ]
            }),
        }),
    })
}

export default Bar;
// Widgets left side
import ArchIcon from "./launcher";
import ResourceMonitor from "./resources";
import UpdateIndicator from "./updates";
import ClientTitle from "./client";

// Widgets center
import Workspaces from "./workspaces";

// Widgets right side
import SettingsBox from "./settings";
import AudioIndicator from "./audio";
import BluetoothIndicator from "./bluetooth";
import NetworkIndicator from "./network";
import SystemTray from "./system-tray";
import Clock from "./clock";
import ShutdownMenu from "./shutdown";



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
                    UpdateIndicator(),
                    ClientTitle(),
                ]
            }),
            center_widget: Widget.Box({
                hpack: "center",
                className: "center",
                children: [
                    Widget.Box({
                        class_name: "rounding-left",
                    }),
                    Workspaces(),
                    Widget.Box({
                        class_name: "rounding-right",
                    })
                ]
            }),
            end_widget: Widget.Box({
                hpack: "end",
                className: "right widgets spacing",
                children: [
                    SettingsBox(),
                    SystemTray(),
                    NetworkIndicator(),
                    AudioIndicator(),
                    BluetoothIndicator(),
                    Clock(),
                    ShutdownMenu(),
                ]
            }),
        }),
    })
}

export default Bar;
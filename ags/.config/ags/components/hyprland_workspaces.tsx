import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import { Variable, bind, exec, execAsync, GLib } from "astal"

import Hyprland from "gi://AstalHyprland";
import { Logger } from "@logging";

// NOTE: Currently, i don't know how to get the monitor index from Gdk.Monitor
// Therefore this workaround is applied.
const MONITORS: { [key: string]: number } = {
    "ROG XG27UQR": 0,
    "PG27UQR": 1,
    "0x6693": 0
};

// import { Gdk } from "astal/gtk3";
//
// export function getMonitorName(display: Gdk.Display, gdkmonitor: Gdk.Monitor)
// {
//     const screen = display.get_default_screen();
//     for (let i = 0; i < display.get_n_monitors(); ++i) {
//         if (gdkmonitor === display.get_monitor(i))
//             return screen.get_monitor_plug_name(i);
//     }
// }

export function WidgetHyprlandWorkspaces({ monitor }: { monitor: Gdk.Monitor }) {
    const hypr = Hyprland.get_default()

    return <box className="Workspaces">
        {bind(hypr, "workspaces").as(wss => wss
            .filter((ws: any) => MONITORS[monitor.get_model()] === ws.monitor.id)
            .filter((ws: any) => !(ws.id >= -99 && ws.id <= -2))
            .sort((a: any, b: any) => a.id - b.id)
            .map((ws: any) => (
                <button
                    className={bind(hypr, "focusedWorkspace").as(fw =>
                        ws === fw ? "focused" : "")}
                    onClicked={() => ws.focus()}>
                    {ws.id}
                </button>
            ))
        )}
    </box>
}


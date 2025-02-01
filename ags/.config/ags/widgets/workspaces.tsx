import { Gdk } from "astal/gtk3"
import { bind } from "astal"

import Hyprland from "gi://AstalHyprland"

// NOTE: Currently, i don't know how to get the monitor index from Gdk.Monitor
// Therefore this workaround is applied.
const MONITORS: { [key: number]: string } = {
    0: "LG Ultra HD",
    1: "ROG XG27UQR",
};

export default function Workspaces({ monitor }: { monitor: Gdk.Monitor }) {
    const hypr = Hyprland.get_default()

    return <box className="Workspaces">
        {bind(hypr, "workspaces").as(wss => wss
            .filter((ws: any) => MONITORS[ws.monitor.id] === monitor.get_model())
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

import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import { Variable, bind, exec, execAsync, GLib } from "astal"

import Hyprland from "gi://AstalHyprland"
import { Logger } from "@logging"

// Here, a solution with the Hyprland object must be found.
const submap = Variable<string>("").poll(500, () => {
    const submap = exec([
        "bash",
        "-c",
        "hyprctl submap"
    ]);
    return submap;
})

function getSubstitute(input: string): string {
    const SUBSTITUTIONS: Record<string, string> = {
        "v": "Neovim",
        "nvim": "Neovim",
    };

    return input in SUBSTITUTIONS ? SUBSTITUTIONS[input] : input;
}

export function WidgetHyprlandClient() {
    const hypr = Hyprland.get_default()
    const focused = bind(hypr, "focusedClient")

    return <box
        className="Client">
        <box>
            {submap().as(value => value === "default" ? <box /> :
                <box className="Submap">
                    <label className="icon" label="󰥻" />
                    <label className="name" label={value} />
                </box>
            )}
        </box>
        <box
            visible={focused.as(Boolean)}>
            {focused.as(client => (
                client && <label label={bind(client, "class").as(v => getSubstitute(v)).as(String)} />
            ))}
        </box>
    </box >
}






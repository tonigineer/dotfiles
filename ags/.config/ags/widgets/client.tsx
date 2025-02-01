import { bind } from "astal"

import Hyprland from "gi://AstalHyprland"


function getSubstitute(input: string): string {
    const SUBSTITUTIONS: Record<string, string> = {
        "v": "Neovim",
        "nvim": "Neovim",
    };

    if (input in SUBSTITUTIONS) {
        return SUBSTITUTIONS[input];
    }

    return input
}

export default function Client() {
    const hypr = Hyprland.get_default()
    const focused = bind(hypr, "focusedClient")

    return <box
        className="Client"
        visible={focused.as(Boolean)}>
        {focused.as(client => (
            client && <label label={bind(client, "class").as(v => getSubstitute(v)).as(String)} />
        ))}
    </box>
}

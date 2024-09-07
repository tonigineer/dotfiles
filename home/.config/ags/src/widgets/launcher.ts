// const HYPRLAND = await Service.import("hyprland");
// import { HYPRLAND } from "./../index";

import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';
const { execAsync } = Utils;

function ArchIcon() {

    return Widget.Box({
        class_name: "launcher-arch",
        children: [
            Widget.Button({
                hpack: "start",
                hexpand: true,
                tooltip_text: "Open rofi | btop.",
                child: Widget.Label({
                    hpack: "start",
                    label: "   ",  // whitespaces uses as padding
                    class_name: "icon",
                }),
                on_primary_click: (_, event) => {
                    execAsync(`rofi -show drun`).catch(print);
                },
                on_secondary_click: (_, event) => {
                    execAsync(`kitty --title float -e btop`).catch(print);
                },
            })
        ]
    })
}

export { ArchIcon }
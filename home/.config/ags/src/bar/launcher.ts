// const HYPRLAND = await Service.import("hyprland");
// import { HYPRLAND } from "./../index";

// import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';

const ArchIcon = () => Widget.Box({
    class_name: "launcher-arch",
    children: [
        Widget.Button({
            hpack: "start",
            hexpand: true,
            tooltip_text: "Open `rofi` application launcher with left click\nand `Btop` in the terminal with right click.",
            // child: Widget.Label({
            //     hpack: "start",
            //     label: " ",
            //     class_name: "icon",
            // }),
            child: Widget.Icon({
                icon: "distributor-logo-archlinux",
                size: 28
            }),
            on_primary_click: (_, event) => {
                App.openWindow("terminal");
            },
            on_secondary_click: (_, event) => {
                Utils.execAsync(`kitty --title float -e btop`).catch(print);
            },
        }),
    ]
})

export default ArchIcon;

// const HYPRLAND = await Service.import("hyprland");
import { HYPRLAND } from "./../index";
import { CONFIG } from "./../../config";

const substitute = CONFIG.substitutions.clients.substitute;

const ClientTitle = () => Widget.Box({
    class_name: "client-box",
    vertical: true,
    children: [
        Widget.Label({
            xalign: 0,
            truncate: 'end',
            maxWidthChars: 25,
            class_name: "client-title",
            // label: HYPRLAND.active.client.bind("title"),
            setup: (self) => self.hook(HYPRLAND.active.client, label => {
                label.label = HYPRLAND.active.client.title.length === 0 ?
                    `Workspace ${HYPRLAND.active.workspace.id}` :
                    substitute(HYPRLAND.active.client.title);
            }),
        }),
        Widget.Label({
            xalign: 0,
            truncate: 'end',
            maxWidthChars: 25,
            class_name: "client-class",
            // label: HYPRLAND.active.client.bind("title"),
            setup: (self) => self.hook(HYPRLAND.active.client, label => { // Hyprland.active.client
                label.label = HYPRLAND.active.client.class.length === 0 ?
                    'Desktop' :
                    substitute(HYPRLAND.active.client.class);
            }),
        }),
    ]
})

export { ClientTitle }
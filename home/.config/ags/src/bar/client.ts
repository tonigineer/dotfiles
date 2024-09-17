// const HYPRLAND = await Service.import("hyprland");
import Hyprland from 'resource:///com/github/Aylur/ags/service/hyprland.js';
import { CONFIG } from "./../../settings";

const substitute = CONFIG.widgets.client.substitutions.substitute;


const ClientTitle = () => Widget.Box({
    class_name: "client",
    vertical: true,
    children: [
        Widget.Label({
            xalign: 0,
            truncate: 'end',
            maxWidthChars: 25,
            class_name: "title-label",
            setup: (self) => self.hook(Hyprland.active.client, label => {
                label.label = Hyprland.active.client.title.length === 0 ?
                    `Workspace ${Hyprland.active.workspace.id}` :
                    substitute(Hyprland.active.client.title);
            }),
        }),
        Widget.Label({
            xalign: 0,
            truncate: 'end',
            maxWidthChars: 25,
            class_name: "class-label",
            setup: (self) => self.hook(Hyprland.active.client, label => {
                label.label = Hyprland.active.client.class.length === 0 ?
                    'Desktop' :
                    substitute(Hyprland.active.client.class);
            }),
        }),
    ]
})

export default ClientTitle;
// const HYPRLAND = await Service.import("hyprland");
import { HYPRLAND } from "./../index";

function ClientTitle() {
    return Widget.Label({
        class_name: "client-title",
        label: HYPRLAND.active.client.bind("title"),
    })
}

export { ClientTitle }
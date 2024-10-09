import Hyprland from "resource:///com/github/Aylur/ags/service/hyprland.js";
import Hypridle from "./../../services/hypridle"


function QuickSettings() {
    function changeDisplayLayout() {
        Hyprland.workspaces.filter(v => v.monitorID !== Hyprland.active.monitor.id)
            .forEach((w) => {
                Hyprland.messageAsync(`dispatch moveworkspacetomonitor ${w.id} ${Hyprland.active.monitor.name}`);
            })
        Hyprland.monitors.filter(v => v.id !== Hyprland.active.monitor.id)
            .forEach((m) => {
                Hyprland.messageAsync(`dispatch dpms ${m.dpmsStatus ? "off" : "on"} ${m.name}`);
            })
    }

    return Widget.Box({
        class_name: "quick-settings",
        vertical: true,
        children: [
            Widget.Box({
                children: [
                    Widget.Box({
                        class_name: "hypridle",
                        child: Widget.Button({
                            cursor: "pointer",
                            class_name: Hypridle.bind("is_active").as(v => v ? "active" : ""),
                            onPrimaryClick: () => { Hypridle.toggle(); },
                            child: Widget.Icon({
                                class_name: "icon",
                                icon: Hypridle.bind("is_active").as(v => `custom-hypridle-${v ? "enabled" : "disabled"}-symbolic`)
                            }),
                        }),
                    }),
                    Widget.Box({ hexpand: true }),
                    Widget.Box({
                        class_name: "display",
                        child:
                            Widget.Button({
                                class_name: Hyprland.bind("monitors").as(v => v.filter((m) => m.dpmsStatus).length > 1 ? "dual" : "single"),
                                cursor: "pointer",
                                onPrimaryClick: () => {
                                    changeDisplayLayout()
                                },
                                child: Widget.Icon({
                                    class_name: "icon",
                                    icon: Hyprland.bind("monitors")
                                        .as(v => `custom-monitors-${v.filter((m) => m.dpmsStatus).length > 1 ? "dual" : "single"}-symbolic`)
                                }),
                            })
                    })
                ]
            }),
        ]
    })
}

export default QuickSettings;
import Hyprland from 'resource:///com/github/Aylur/ags/service/hyprland.js';


const updateHypridleState = () => {
    hypridleIsActive.setValue(Utils.exec(["bash", "-c", `pgrep hypridle`]) !== "");
}

const hypridleIsActive = Variable(true)
updateHypridleState();

const SettingsBox = () => Widget.Box({
    class_name: "settings",
    children: [
        Widget.Button({
            class_name: "hypridle",
            cursor: "pointer",
            onPrimaryClick: (self) => {
                Utils.execAsync(["bash", "-c", `${hypridleIsActive.value ? "pkill hypridle" : "hypridle"}`]);
                updateHypridleState();
            },
            child: Widget.Icon({
                class_name: "icon",
                icon: hypridleIsActive.bind().as(v => `custom-hypridle-${v ? "enabled" : "disabled"}-symbolic`)
            }),
            // TODO parse durations from config file
            tooltip_text: hypridleIsActive.bind().as(v => `Hypridle ${v ? "ENABLED\n\n  5min    󰒲  30min" : "DISABLED"}`)
        }),
        Widget.Button({
            class_name: "screens",
            cursor: "pointer",
            onPrimaryClick: (self) => {
                Hyprland.workspaces.filter(v => v.monitorID !== Hyprland.active.monitor.id).forEach((w) => {
                    Hyprland.messageAsync(`dispatch moveworkspacetomonitor ${w.id} ${Hyprland.active.monitor.name}`);
                })
                Hyprland.monitors.filter(v => v.id !== Hyprland.active.monitor.id).forEach((m) => {
                    Hyprland.messageAsync(`dispatch dpms ${m.dpmsStatus ? "off" : "on"} ${m.name}`);
                })
            },
            child: Widget.Icon({
                class_name: "icon",
                icon: Hyprland.bind("monitors")
                    .as(v => `custom-monitors-${v.filter((m) => m.dpmsStatus).length > 1 ? "dual" : "single"}-symbolic`)
            }),
            tooltip_text: `Toggle all other monitors.`
        })
    ]
})



export default SettingsBox;

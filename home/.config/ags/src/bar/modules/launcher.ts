const APP_LAUNCHER = "rofi -show drun";
const TASK_MANAGER = "kitty --title float -e btop";


const ArchIcon = () => Widget.Box({
    class_name: "launcher",
    children: [
        Widget.Button({
            child: Widget.Icon({
                icon: "distributor-logo-archlinux",
                size: 28
            }),
            on_primary_click: (_, event) => {
                // App.openWindow("terminal");
                Utils.execAsync(["bash", "-c", APP_LAUNCHER]).catch(print);
            },
            on_secondary_click: (_, event) => {
                Utils.execAsync(["bash", "-c", TASK_MANAGER]).catch(print);
            },
            cursor: "pointer",
            tooltip_text: " Application Launcher   System Monitor ",
        }),
    ]
})

export default ArchIcon;

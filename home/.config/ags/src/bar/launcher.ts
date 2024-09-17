import { CONFIG as cfg } from "./../../settings";


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
                Utils.execAsync(["bash", "-c", cfg.apps.appLauncher]).catch(print);
            },
            on_secondary_click: (_, event) => {
                Utils.execAsync(["bash", "-c", cfg.apps.taskManager]).catch(print);
            },
            cursor: "pointer",
            tooltip_text: "Open application manager or\ntask system monitor.",
        }),
    ]
})

export default ArchIcon;

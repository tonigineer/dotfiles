import Resources from "src/services/resources";
import { CONFIG as cfg } from "./../../settings";
import { AnimatedCircProg } from "../utils/circular_progress.js";

enum id {
    cpu = "cpu",
    ram = "ram",
    disk = "disk",
    gpu = "gpu",
}


const resourceProgress = (id: id, icon: String) => Widget.Box({
    children: [
        Widget.Overlay({
            child:
                Widget.Label({
                    className: `icon`,
                    label: `${icon}`,
                }),
            overlays: [AnimatedCircProg({
                className: `circular`,
                vpack: 'center',
                hpack: 'center',
            }).hook(Resources, self => {
                self.css = `font-size: ${Resources[id].widget_value}px;`;
            }, "changed")]
        }),
        Widget.Label({
            className: `label`,
        }).hook(Resources, self => {
            self.label = `${Resources[id].widget_value.toFixed(0).padStart(2, "0")} `
        }, "changed")
    ],
    tooltip_text: Resources.bind(id).as(v => v.tooltip_text)
});


const ResourceMonitor = () => Widget.Box({
    class_name: `resources`,
    children: [
        Widget.Button({
            class_name: "cpu",
            cursor: "pointer",
            onPrimaryClick: () => Utils.execAsync(`${cfg.apps.taskManager}`).catch(print),
            child: resourceProgress(id.cpu, "C"),

        }),
        Widget.Button({
            class_name: "ram",
            cursor: "pointer",
            onPrimaryClick: () => Utils.execAsync(`${cfg.apps.taskManager}`).catch(print),
            child: resourceProgress(id.ram, "M"),

        }),
        Widget.Button({
            class_name: "disk",
            cursor: "pointer",
            onPrimaryClick: () => Utils.execAsync(`${cfg.apps.fileManager}`).catch(print),
            child: resourceProgress(id.disk, "D"),

        }),
        Widget.Revealer({
            revealChild: false,
            transitionDuration: 1000,
            transition: 'slide_right',
            child: Widget.Button({
                class_name: "gpu",
                cursor: "pointer",
                onPrimaryClick: () => Utils.execAsync(`${cfg.apps.fileManager}`).catch(print),
                child: resourceProgress(id.gpu, "G"),

            }),
        }).hook(Resources, self => self.reveal_child = Resources.gpu.widget_value > 25)
    ]
})

export default ResourceMonitor;
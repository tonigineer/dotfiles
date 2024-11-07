import Resources from "src/services/resources";
import { AnimatedCircProg } from "./utils/circular_progress.js";

const TASK_MANAGER = "kitty --title float -e btop";
const FILE_MANAGER = "kitty --title float -e yazi";

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
            onPrimaryClick: () => Utils.execAsync(`${TASK_MANAGER}`).catch(print),
            // child: resourceProgress(id.cpu, "C"),
            child: Widget.Box({
                children: [Widget.Icon({
                    icon: "resource-cpu",
                    size: 18,
                }),
                Widget.Label({
                    label: Resources.bind("cpu")
                        .as(v => { return ` ${Resources[id.cpu].widget_value.toFixed(0).padStart(2, "0")} ` })
                })
                ]
            })

        }),
        Widget.Button({
            class_name: "ram",
            cursor: "pointer",
            onPrimaryClick: () => Utils.execAsync(`${TASK_MANAGER}`).catch(print),
            // child: resourceProgress(id.ram, "M"),
            child: Widget.Box({
                children: [Widget.Icon({
                    css: "margin-top: -0.3rem;",
                    icon: "resource-ram",
                    size: 18,
                }),
                Widget.Label({
                    label: Resources.bind("ram")
                        .as(v => { return ` ${Resources[id.ram].widget_value.toFixed(0).padStart(2, "0")} ` })
                })
                ]
            })

        }),
        Widget.Button({
            class_name: "disk",
            cursor: "pointer",
            onPrimaryClick: () => Utils.execAsync(`${FILE_MANAGER}`).catch(print),
            // child: resourceProgress(id.disk, "D"),
            child: Widget.Box({
                children: [Widget.Icon({
                    icon: "resource-disk",
                    size: 18,
                }),
                Widget.Label({
                    label: Resources.bind("disk")
                        .as(v => { return ` ${Resources[id.disk].widget_value.toFixed(0).padStart(2, "0")} ` })
                })
                ]
            })

        }),
        Widget.Revealer({
            revealChild: false,
            transitionDuration: 1000,
            transition: 'slide_right',
            child: Widget.Button({
                class_name: "gpu",
                cursor: "pointer",
                onPrimaryClick: () => Utils.execAsync(`${TASK_MANAGER}`).catch(print),
                // child: resourceProgress(id.gpu, "G"),
                child: Widget.Box({
                    children: [Widget.Icon({
                        icon: "resource-gpu",
                        size: 18,
                    }),
                    Widget.Label({
                        label: Resources.bind("gpu")
                            .as(v => { return ` ${Resources[id.gpu].widget_value.toFixed(0).padStart(2, "0")} ` })
                    })
                    ]
                })
            }),
        }).hook(Resources, self => self.reveal_child = Resources.gpu.widget_value > 25)
    ]
})

export default ResourceMonitor;
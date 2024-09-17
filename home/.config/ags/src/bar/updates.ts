import { CONFIG as cfg } from "./../../settings";
import Yay from "src/services/yay";


const UpdateIndicator = () => Widget.Box({
    children: [
        Widget.Revealer({
            class_name: "updates",
            transitionDuration: 1000,
            transition: 'slide_right',
            child: Widget.Button({
                cursor: "pointer",
                child: Widget.Box({
                    children: [
                        Widget.Label({
                            class_name: "icon",
                            label: "󱧘 "
                        }),
                        Widget.Label({
                            class_name: "label",
                        }).hook(Yay, self => { self.label = Yay.updates.pending.toString() }),
                    ]
                }),
                on_clicked: () => Utils
                    .execAsync(["bash", "-c", `${cfg.apps.updater}`]).catch(print),
            }),
            setup: self => self.hook(Yay, () => {
                self.reveal_child = Yay.updates.pending > 0;
                self.tooltip_text = Yay.updates.tooltip_text;
            }, "changed")
        })
    ]
})

export default UpdateIndicator;

import Yay from "src/services/yay";


const UPDATER = "kitty --title float -e yay -Syu"

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
                        // Widget.Label({
                        //     class_name: "icon",
                        //     label: "󱧘 "
                        // }),
                        Widget.Icon({
                            icon: "resource-updates",
                            size: 26
                        }),
                        Widget.Label({
                            class_name: "label",
                        }).hook(Yay, self => { self.label = ` ${Yay.updates.pending.toString()}` }),
                    ]
                }),
                on_clicked: () => Utils
                    .execAsync(["bash", "-c", `${UPDATER}`]).catch(print),
            }),
            setup: self => self.hook(Yay, () => {
                self.reveal_child = Yay.updates.pending > 1;
                self.tooltip_text = Yay.updates.tooltip_text;
            }, "changed")
        })
    ]
})

export default UpdateIndicator;

import { CONFIG } from "./../../config";


const SHUTDOWN_COMMANDS = {
    "shutdown": "",
    "reboot": "",
    "suspend": "",
    "hibernate": ""
}

const ICONS = {
    "true": "󰤁",
    "false": "󰤂",
    "shutdown": "󰐥",
    "reboot": "󰜉",
    "suspend": "󱫟",
    "hibernate": "󱖐",
}


const toggle = Variable(false);


const Button = () => Widget.Button({
    class_name: "shutdown opener",
    label: ICONS[String(toggle.value)],
    on_clicked: (self) => {
        self.label = ICONS[String(!toggle.value)];
        toggle.value = !toggle.value;
    },
})


const Menu = () => Widget.Revealer({
    revealChild: toggle.value,
    transitionDuration: 1000,
    transition: 'slide_right',
    attribute: false,
    child: Widget.Box({
        class_name: "shutdown menu",
        children: [
            Widget.Button({
                class_name: "shutdown menu poweroff",
                label: ICONS["shutdown"],
                on_clicked: () => {
                    toggle.value = !toggle.value;
                    Utils.execAsync(`systemctl poweroff`);
                },
            }),
            Widget.Button({
                class_name: "shutdown menu reboot",
                label: ICONS["reboot"],
                on_clicked: () => {
                    toggle.value = !toggle.value;
                    Utils.execAsync(`systemctl reboot`);
                },
            }),
            Widget.Button({
                class_name: "shutdown menu hibernate",
                label: ICONS["hibernate"],
                on_clicked: () => {
                    toggle.value = !toggle.value;
                    Utils.execAsync(`systemctl hibernate`);
                },
            }),
            Widget.Button({
                class_name: "shutdown menu suspend",
                label: ICONS["suspend"],
                on_clicked: () => {
                    toggle.value = !toggle.value;
                    Utils.execAsync(`systemctl suspend-then-hibernate`);
                },
            }),
        ]
    }),
    setup: self => self.hook(toggle, () => {
        self.reveal_child = toggle.value;
    })
})

const ShutdownMenu = () => Widget.Box({
    class_name: "shutdown",
    children: [
        Menu(), Button()]
})

export { ShutdownMenu }

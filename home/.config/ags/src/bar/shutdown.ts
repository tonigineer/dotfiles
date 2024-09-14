const COMMANDS = {
    "shutdown": "systemctl poweroff",
    "reboot": "systemctl restart",
    "hibernate": "systemctl hibernate",
    "suspend": "systemctl suspend",
}

const ICONS = {
    "true": "󰤁",
    "false": "󰤂",
    "shutdown": "󰐥",
    "reboot": "󰜉",
    "suspend": "󱫟",
    "hibernate": "󱖐",
}

const reveal_child = Variable(false);

const ShowButton = () => Widget.Button({
    label: reveal_child.bind().as(v => v ? "󰤁" : "󰤂"),
    cursor: "pointer",
    on_clicked: () => {
        reveal_child.value = !reveal_child.value;
    },
})

const Menu = () => Widget.Revealer({
    // revealChild: reveal_child.value,
    revealChild: reveal_child.bind(),
    transitionDuration: 1000,
    transition: 'slide_right',
    cursor: "pointer",
    child: Widget.Box({
        class_name: "menu",
        children:
            Object.keys(COMMANDS).map((k, v) => Widget.Button({
                class_name: `${k}`,
                label: ICONS[k],
                cursor: "pointer",
                on_clicked: () => {
                    reveal_child.value = !reveal_child.value;
                    Utils.execAsync(["bash", "-c", `${v}`]);
                }
            })
            )
    }),
})

const ShutdownMenu = () => Widget.Box({
    class_name: "shutdown-menu",
    children: [
        Menu(),
        ShowButton()]
})

export default ShutdownMenu;

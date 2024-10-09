function ShutdownMenu() {
    const COMMANDS = {
        "shutdown": "systemctl poweroff",
        "reboot": "systemctl reboot",
        "hibernate": "systemctl hibernate",
        "suspend": "systemctl hybrid-sleep",
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

    const ShowShutdownMenu = () => Widget.Button({
        class_name: "opener",
        // label: reveal_child.bind().as(v => v ? "󰤁" : "󰤂"),
        child: Widget.Icon("button-power"),
        cursor: "pointer",
        tooltip_text: "Open Shutdown Menu",
        on_clicked: () => {
            reveal_child.value = !reveal_child.value;
        },
    })

    const TakeScreenshot = () => Widget.Button({
        class_name: "opener",
        // label: reveal_child.bind().as(v => v ? "󰤁" : "󰤂"),
        child: Widget.Icon({
            icon: "button-screenshot",
            size: 30
        }),
        cursor: "pointer",
        tooltip_text: "Take Screenshot",
        on_clicked: () => {
            Utils.execAsync(["bash", "-c", "capture --image"])
        },
    })

    const ShutdownMenu = () => Widget.Revealer({
        revealChild: reveal_child.bind(),
        transitionDuration: 500,
        transition: 'slide_down',
        cursor: "pointer",
        child: Widget.Box({
            class_name: "menu",
            children:
                Object.keys(COMMANDS).map((k, v) => Widget.Button({
                    class_name: `${k}`,
                    label: ICONS[k],
                    cursor: "pointer",
                    hexpand: true,
                    on_clicked: () => {
                        reveal_child.value = !reveal_child.value;
                        Utils.execAsync(["bash", "-c", COMMANDS[k]]).catch(print);
                    },
                    tooltip_text: k.charAt(0).toUpperCase() + k.slice(1)
                }))
        }),
    })

    return Widget.Box({
        class_name: "shutdown-menu",
        vertical: true,
        children: [
            Widget.Box({
                children: [
                    TakeScreenshot(),
                    Widget.Box({ hexpand: true }),
                    ShowShutdownMenu()]
            }),
            ShutdownMenu()]
    })
}

export default ShutdownMenu;
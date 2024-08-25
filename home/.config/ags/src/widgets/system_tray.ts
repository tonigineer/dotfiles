const SYSTEM_TRAY = await Service.import("systemtray")

function SystemTray() {
    const ITEMS = SYSTEM_TRAY.bind("items")
        .as(items => items.map(item => Widget.Button({
            child: Widget.Icon({
                class_name: "system_tray_icon",
                icon: item.bind("icon")
            }),
            on_primary_click: (_, event) => item.activate(event),
            on_secondary_click: (_, event) => item.openMenu(event),
            tooltip_markup: item.bind("tooltip_markup"),
        })))

    return Widget.Box({
        class_name: "system_tray",
        children: ITEMS,
    })
}

export { SystemTray }
import Systemtray from 'resource:///com/github/Aylur/ags/service/systemtray.js';


function customIcons(icon) {
    const substitutes = {
        "chrome_status_icon_1": "custom-icon-vesktop",
        "steam": "steam"
    }
    return substitutes[icon["emitter"]["id"]];
}

function SystemTray() {
    const ITEMS = Systemtray.bind("items")
        .as(items => items.map(item => Widget.Button({
            child: Widget.Icon({
                class_name: "icon",
                icon: customIcons(item.bind("icon")),
                size: 18
            }),
            on_primary_click: (_, event) => item.activate(event),
            on_secondary_click: (_, event) => item.openMenu(event),
            tooltip_markup: item.bind("tooltip_markup"),
        })))

    return Widget.Box({
        class_name: "system-tray",
        children: ITEMS,
    })
}

export default SystemTray;
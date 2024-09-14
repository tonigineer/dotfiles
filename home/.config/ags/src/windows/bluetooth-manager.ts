// import Widget from "resource:///com/github/Aylur/ags/widget.js";
// // @ts-ignore
import Bluetooth from "resource:///com/github/Aylur/ags/service/bluetooth.js";
import Hyprland from "resource:///com/github/Aylur/ags/service/hyprland.js";
// import Gtk from "gi://Gtk?version=3.0";

const header = () => Widget.Box({
    class_name: "header",
    spacing: 40,
    children: [
        Widget.Icon({
            class_name: "icon",
            icon: "custom-audio-bluetooth-on-symbolic"
        }),
        Widget.Box({ hexpand: true }),
        Widget.Label({
            class_name: "label",
            label: "Bluetooth"
        }),
        Widget.Box({ hexpand: true }),
        Widget.Button({
            on_clicked: () => Utils.execAsync(`kitty --title float -e bluetoothctl`)
                .catch(logError),
            child: Widget.Icon("custom-audio-settings-symbolic"),
        })
    ]
})

const selector = () => Widget.Box({
    class_name: "selector",
    hexpand: true,
    vertical: true,
}).hook(Bluetooth, box => {
    box.children = Bluetooth.devices.map(device => Widget.Box({
        vexpand: true,
        hexpand: true,
        class_name: "item",
        children: [
            Widget.Icon({
                class_name: "icon",
                icon: device.icon_name + "-symbolic"
            }),
            Widget.Label({
                class_name: "label",
                label: device.name
            }),
            Widget.Box({ hexpand: true }),
            device.connecting
                ? Widget.Icon({
                    class_name: "spinner",
                    icon: "custom-spinning-symbolic"
                })
                : Widget.Switch({
                    active: device.connected
                }).on("notify::active", ({ active }) => {
                    if (active !== device.connected) device.setConnection(active);
                })
        ],
    }));
})

const BluetoothManager = Widget.Window({
    anchor: ["top", "right"],
    class_name: "bluetooth-manager",
    keymode: "exclusive",
    monitor: Hyprland.active.bind("monitor").as(m => m.id),
    name: "bluetooth-manager",
    margins: [15, 15],
    layer: "overlay",
    visible: false,
    child: Widget.Box({
        vertical: true,
        children: [
            header(),
            selector()]
    }),
    setup: self => self.keybind("Escape", () => {
        App.closeWindow("bluetooth-manager")
    }),
});

export default BluetoothManager;
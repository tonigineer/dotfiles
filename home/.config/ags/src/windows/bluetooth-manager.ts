import Bluetooth from "resource:///com/github/Aylur/ags/service/bluetooth.js";
import Hyprland from "resource:///com/github/Aylur/ags/service/hyprland.js";


const header = () => Widget.Box({
    class_name: "header",
    children: [
        Widget.Icon({
            class_name: "state",
        }).hook(Bluetooth, self => self.icon = !Bluetooth.enabled
            ? "custom-audio-bluetooth-off-symbolic"
            : Bluetooth.connected_devices.length === 0
                ? "custom-audio-bluetooth-on-symbolic"
                : "custom-audio-bluetooth-connected-symbolic"
        ),
        Widget.Box({ hexpand: true }),
        Widget.Label({
            class_name: "label",
            label: "Bluetooth"
        }),
        Widget.Box({ hexpand: true }),
        Widget.Button({
            cursor: "pointer",
            on_clicked: () => Utils.execAsync(`kitty --title float -e bluetoothctl`)
                .catch(logError),
            child: Widget.Label({
                class_name: "settings",
                label: " ",
            })
        }),
        Widget.Separator({ css: "min-width: 0.25rem;" }),
        Widget.Button({
            cursor: "pointer",
            on_clicked: () => App.closeWindow("bluetooth-manager"),
            child: Widget.Label({
                class_name: "close",
                label: "󱄊",
            }),
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
    class_name: "bluetooth-manager",
    name: "bluetooth-manager",
    monitor: Hyprland.active.bind("monitor").as(m => m.id),
    anchor: ["top", "right"],
    layer: "overlay",
    margins: [15, 15],
    visible: false,
    child: Widget.Box({
        vertical: true,
        children: [
            header(),
            selector()]
    }),
    // keymode: "exclusive",
    // setup: self => self.keybind("Escape", () => {
    //     App.closeWindow("bluetooth-manager")
    // }),
});

export default BluetoothManager;
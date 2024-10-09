import Bluetooth from "resource:///com/github/Aylur/ags/service/bluetooth.js";
import Hyprland from "resource:///com/github/Aylur/ags/service/hyprland.js";


function BluetoothControl() {
    const Icon = () => Widget.Button({
        on_clicked: () => {
            Bluetooth.enabled = !Bluetooth.enabled;
        },
        on_secondary_click: () => {
            Utils.execAsync(`kitty --title float -e bluetoothctl`)
        },
        child: Widget.Icon({
            size: 20,
        }).hook(Bluetooth, self => self.icon = !Bluetooth.enabled
            ? "bluetooth-disabled-symbolic"
            : Bluetooth.connected_devices.length === 0
                ? "bluetooth-enabled-symbolic"
                : "bluetooth-connected-symbolic"
        )
    })

    const ButtonRevealList = () => Widget.Button({
        child: Widget.Icon({
            icon: "button-arrow-down-symbolic",
            size: 16,
        }),
        onClicked: (self) => {
            DeviceList.reveal_child = !DeviceList.child_revealed;
            self.child.icon_name = `button-arrow-${DeviceList.reveal_child ? "up" : "down"}-symbolic`;
        }
    })

    const DeviceList = Widget.Revealer({
        reveal_child: false,
        child: Widget.Box()
    }).hook(Bluetooth, self => {
        self.child = Widget.Box({
            class_name: "selector",
            vertical: true,
            children: Bluetooth.devices.map(device => Widget.Box({
                class_name: "item",
                children: [
                    Widget.Icon({
                        class_name: "icon",
                        icon: device.icon_name + "-symbolic"
                    }),
                    Widget.Label({
                        class_name: "label",
                        label: device.name.slice(0, 20)
                    }),
                    Widget.Box({ hexpand: true }),
                    device.connecting
                        ? Widget.Icon({
                            class_name: "spin",
                            icon: "spinner-symbolic",
                            size: 20,
                        })
                        : Widget.Switch({
                            active: device.connected
                        }).on("notify::active", ({ active }) => {
                            if (active !== device.connected) device.setConnection(active);
                        })
                ],
            }))
        })
    })


    return Widget.Box({
        class_name: "bluetooth-control",
        vertical: true,
        children: [
            Widget.Box({
                class_name: "header",
                children: [
                    Icon(),
                    Widget.Box({ hexpand: true }),
                    Widget.Label({
                        css: "font-size: 16px;",
                        label: Bluetooth.bind("connected_devices").as(v => Bluetooth.enabled ? `Devices ${v.length.toString()}/${Bluetooth.devices.length}` : "Disabled")
                    }),
                    Widget.Box({ hexpand: true }),
                    ButtonRevealList(),
                ]
            }),
            Widget.Box({
                class_name: "list",
                children: [
                    DeviceList
                ]
            })
        ]
    })
}

export default BluetoothControl;
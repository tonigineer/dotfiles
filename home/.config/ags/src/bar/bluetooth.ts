import Widget from "resource:///com/github/Aylur/ags/widget.js";
// @ts-ignore
import Bluetooth from "resource:///com/github/Aylur/ags/service/bluetooth.js";
import Gtk from "gi://Gtk?version=3.0";

import BluetoothManager from "src/windows/bluetooth-manager";

const Switch = Widget.subclass(Gtk.Switch, "AgsSwitch");
const TextView = Widget.subclass(Gtk.TextView, "AgsTextView");

const BluetoothIndicator = () => Widget.Box({
    class_name: "bluetooth",
    children: [
        Widget.Button({
            onPrimaryClick: () => { BluetoothManager.visible = !BluetoothManager.visible },
            onSecondaryClick: () => { Bluetooth.enabled = !Bluetooth.enabled },
            child: Widget.Icon({
                class_name: "icon",
            }).hook(Bluetooth, self => {
                self.icon = !Bluetooth.enabled
                    ? "custom-audio-bluetooth-off-symbolic"
                    : Bluetooth.connected_devices.length === 0
                        ? "custom-audio-bluetooth-on-symbolic"
                        : "custom-audio-bluetooth-connected-symbolic"
            }),
        }),
    ]
})

export default BluetoothIndicator;

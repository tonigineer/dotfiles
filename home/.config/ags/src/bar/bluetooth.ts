import Bluetooth from "resource:///com/github/Aylur/ags/service/bluetooth.js";


const BluetoothIndicator = () => Widget.Box({
    class_name: "bluetooth",
    children: [
        Widget.Button({
            onPrimaryClick: () => { App.toggleWindow("bluetooth-manager") },
            onSecondaryClick: () => { Bluetooth.enabled = !Bluetooth.enabled },
            cursor: "pointer",
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

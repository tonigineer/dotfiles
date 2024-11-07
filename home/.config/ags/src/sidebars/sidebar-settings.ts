import Hyprland from 'resource:///com/github/Aylur/ags/service/hyprland.js';
import Battery from 'resource:///com/github/Aylur/ags/service/battery.js';

import AudioControl from './modules/audio';
import BluetoothControl from './modules/bluetooth';
import Calendar from "./modules/calendar";
import PowerProfiles from './modules/power-profiles';
import NetworkControl from './modules/network';
import ShutdownMenu from "./modules/shutdown-menu";
import QuickSettings from "./modules/quick-settings";


const SessionInfo = () => Widget.Box({
    class_name: "session-info",
    children: [Widget.Label("dfas")]
})

const MediaControl = () => Widget.Box({
    class_name: "media-control",
    children: [Widget.Label("dfas")]
})

const SidebarSettings = Widget.Window({
    class_name: "sidebar-settings",
    name: "SidebarSettings",
    monitor: Hyprland.active.bind("monitor").as(m => SidebarSettings.visible ? SidebarSettings.monitor : m.id),
    anchor: ["top", "right", "bottom", "right"],
    exclusivity: "exclusive",
    layer: "top",
    keymode: "on-demand",
    margins: [5, 7.5, 5.0, 2.5],
    visible: false,
    child: Widget.Box({
        attribute: {
            monitor: null
        },
        vertical: true,
        children: [
            ShutdownMenu(),
            Calendar(),
            PowerProfiles(),
            QuickSettings(),
            NetworkControl(),
            AudioControl(),
            BluetoothControl(),
            // SessionInfo(),
            // MediaControl()
        ]
    })
})

export default SidebarSettings;
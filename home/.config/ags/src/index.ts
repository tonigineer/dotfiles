import Hyprland from 'resource:///com/github/Aylur/ags/service/hyprland.js';

// import AudioManager from "./windows/audio-manager";
import Bar from "./bar/index";
// import PowerManager from "./windows/power-manager";
// import BluetoothManager from "./windows/bluetooth-manager";
// import Dota from './windows/dota';
// import NetworkManager from "./windows/network-manager";
import IndicatorVolume from "./indicators/volume";
import SidebarSettings from './sidebars/sidebar-settings';
// import Battery from 'resource:///com/github/Aylur/ags/service/battery.js';

// import AppLauncher from "./launcher/launcher";

App.addIcons(`${App.configDir}/assets`)


App.config({
    windows: [
        // AudioManager,
        // BluetoothManager,
        // // Dota,
        // NetworkManager,
        // Battery.available ? PowerManager : Widget.Window(),
        // AppLauncher,
        SidebarSettings,
        IndicatorVolume,
    ]
})

export default {
    windows: [
        Hyprland.monitors.map((m) => Bar(m)),
    ]
};
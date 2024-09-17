import Hyprland from 'resource:///com/github/Aylur/ags/service/hyprland.js';

import AudioManager from "./windows/audio-manager";
import Bar from "./bar/index";
import BluetoothManager from "./windows/bluetooth-manager";
// import Dota from './windows/dota';
import NetworkManager from "./windows/network-manager";
import TerminalWindow from './windows/terminal';
import VolumeBar from "./windows/volume-bar";


App.addIcons(`${App.configDir}/assets`)


App.config({
    windows: [
        AudioManager,
        BluetoothManager,
        // Dota,
        NetworkManager,
        TerminalWindow,
        VolumeBar,
    ]
})

export default {
    windows: [
        Hyprland.monitors.map((m) => Bar(m)),
    ]
};
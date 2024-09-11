import Hyprland from 'resource:///com/github/Aylur/ags/service/hyprland.js';

import Bar from "./bar/index";
import VolumeBar from "./windows/volume-bar";
import AudioManager from './windows/audio-manager';

App.addIcons(`${App.configDir}/assets`)

export default {
    windows: [
        Hyprland.monitors.map((m) => Bar(m.id)),
        VolumeBar,
        AudioManager
        // BarCornerTopleft(0),
        // BarCornerTopleft(1)
    ]

};


// import { RoundedCorner } from "./utils/rounded_corner";
// import Cairo from 'gi://cairo?version=1.0';

// export const dummyRegion = new Cairo.Region();
// export const enableClickthrough = (self) => self.input_shape_combine_region(dummyRegion);

// export const BarCornerTopleft = (monitor = 0) => Widget.Window({
//     monitor,
//     name: `barcornertl${monitor}`,
//     layer: 'top',
//     anchor: ['top', 'left'],
//     exclusivity: 'normal',
//     visible: true,
//     child: RoundedCorner('topleft', { className: 'corner', }),
//     setup: enableClickthrough,
// });
// export const BarCornerTopright = (monitor = 0) => Widget.Window({
//     monitor,
//     name: `barcornertr${monitor}`,
//     layer: 'top',
//     anchor: ['top', 'right'],
//     exclusivity: 'normal',
//     visible: true,
//     child: RoundedCorner('topright', { className: 'corner', }),
//     setup: enableClickthrough,
// });

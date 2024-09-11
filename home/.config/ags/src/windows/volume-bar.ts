import Audio from 'resource:///com/github/Aylur/ags/service/audio.js';
import Hyprland from 'resource:///com/github/Aylur/ags/service/hyprland.js';


const VolumeSlider = () => Widget.Slider({
    hexpand: true,
    draw_value: false,
    on_change: ({ value }) => {
        Audio["speaker"].volume = value;
    },
}).hook(Audio, slider => {
    if (!Audio["speaker"]) return;

    slider.sensitive = !Audio["speaker"]?.stream.is_muted;
    slider.value = Audio["speaker"].volume;

    // Necessary to have automatic timeout
    VolumeBar.attribute.last_change = Date.now();
    if (Audio["speaker"].volume != VolumeBar.attribute.last_value) {
        VolumeBar.monitor = Hyprland.active.monitor.id;
        VolumeBar.visible = true;
    }
    VolumeBar.attribute.last_value = Audio["speaker"].volume;

}, "speaker" + "-changed");

const VolumeBar = Widget.Window({
    class_name: "volume",
    name: `volume-bar`,
    attribute: {
        last_change: Date.now(),
        last_value: Audio["speaker"].volume
    },
    monitor: 1,
    child: Widget.Box({
        children: [VolumeSlider()],
    }),
    visible: false,
    anchor: ["bottom", "left", "right"],
    layer: "overlay",
    margins: [100, 600],
})

// Automatic timeout for VolumeBar
const id = Utils.interval(500, () => {
    VolumeBar.visible = !(Date.now() - VolumeBar.attribute.last_change > 2000);
})

export default VolumeBar;
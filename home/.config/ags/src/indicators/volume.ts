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

    slider.sensitive = Audio["speaker"]?.is_muted === null ? false : !Audio["speaker"]?.is_muted;
    slider.value = Audio["speaker"].volume;

    // Necessary to have automatic timeout
    IndicatorVolume.attribute.last_change = Date.now();
    if (Audio["speaker"].volume != IndicatorVolume.attribute.last_value) {
        IndicatorVolume.monitor = Hyprland.active.monitor.id;
        IndicatorVolume.visible = true;
    }
    IndicatorVolume.attribute.last_value = Audio["speaker"].volume;

}, "speaker" + "-changed");

const IndicatorVolume = Widget.Window({
    class_name: "volume",
    name: `volume-bar`,
    attribute: {
        last_change: Date.now(),
        last_value: Audio["speaker"].volume
    },
    monitor: Hyprland.active.monitor.id,
    child: Widget.Box({
        children: [VolumeSlider()],
    }),
    visible: false,
    anchor: ["bottom", "left", "right"],
    layer: "overlay",
    margins: [100, 600],
})

// Automatic timeout for IndicatorVolume
const id = Utils.interval(500, () => {
    IndicatorVolume.visible = !(Date.now() - IndicatorVolume.attribute.last_change > 2000);
})

export default IndicatorVolume;
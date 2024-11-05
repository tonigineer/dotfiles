import Audio from 'resource:///com/github/Aylur/ags/service/audio.js';
import Hyprland from 'resource:///com/github/Aylur/ags/service/hyprland.js';

const VANISH_TIME = 1000;
const DYSFUNCTIONAL_OUTPUT_DEVICE = "alsa_output.usb-Razer_Razer_Leviathan_V2_X_000000000000000-01.analog-stereo"

const VolumeSlider = () => Widget.Slider({
    hexpand: true,
    draw_value: false,
    on_change: ({ value }) => {
        Audio["speaker"].volume = value;
    },
})
    .hook(Audio, slider => {
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

        // --- WORKAROUND [specific to Z790E] ---
        // This audio device does not react to changes of its volume. Therefore
        // the volume of the streams are changed.
        if (Audio.speaker.name === DYSFUNCTIONAL_OUTPUT_DEVICE)
            Audio.apps.forEach(v => v.volume = Audio.speaker.volume)
    }, "speaker" + "-changed")
    .hook(Audio, _slider => {
        // --- WORKAROUND [specific to Z790E] ---
        // This hook changes the volume of all streams to 50%.
        // Otherwise, lowering the volume of the speaker needs to
        // go as low as 2%, which is nasty to `handle/set up`.
        if (Audio.speaker.name !== DYSFUNCTIONAL_OUTPUT_DEVICE)
            Audio.apps.forEach(v => v.volume = 0.50)
    }, "stream-added");

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
    exclusivity: "ignore",
    anchor: ["bottom", "left", "right"],
    layer: "overlay",
    // margins: [0, 1920 * 0.25, 1080 * 0.0, 1920 * 0.25],
})

// Automatic timeout for IndicatorVolume
const id = Utils.interval(500, () => {
    IndicatorVolume.visible = !(Date.now() - IndicatorVolume.attribute.last_change > VANISH_TIME);
})

export default IndicatorVolume;
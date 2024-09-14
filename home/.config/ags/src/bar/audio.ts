import Audio from 'resource:///com/github/Aylur/ags/service/audio.js';


const MicrophoneIndicator = () => Widget.Box({
    className: "microphone",
    children: [
        Widget.Button({
            onPrimaryClick: () => {
                App.toggleWindow("audio-manager");
            },
            onSecondaryClick: () => Utils.execAsync(`pavucontrol -t 4`).catch(logError),
            onMiddleClick: () => { Audio.microphone.is_muted = !Audio.microphone.is_muted },
            onScrollUp: () => { Audio.microphone.volume += 0.025 },
            onScrollDown: () => { Audio.microphone.volume -= 0.025 },
            css: "font-size: 20px;",
            child: Widget.Box({
                children: [
                    Widget.Icon().hook(Audio.microphone, self => {
                        const vol = Audio.microphone.volume * 100;
                        self.icon = Audio.microphone.is_muted ?
                            "custom-audio-microphone-symbolic" :
                            "custom-audio-microphone-mute-symbolic"
                        self.tooltip_text = `Microphone ${Math.floor(vol)}%`;
                        self.class_name = "icon";
                    }),
                    Widget.Label({
                        class_name: "value",
                        label: Audio.microphone.bind("volume").as(v => {
                            return `${Math.floor(v * 100).toString().padStart(2, '0')}`
                        }),
                    }),
                ]
            })
        }),

    ]
})

const VolumeIndicator = () => Widget.Box({
    className: "volume",
    children: [
        Widget.Button({
            onPrimaryClick: () => {
                App.toggleWindow("audio-manager");
            },
            onSecondaryClick: () => Utils.execAsync(`pavucontrol -t 3`).catch(logError),
            onMiddleClick: () => { Audio.speaker.is_muted = !Audio.speaker.is_muted },
            onScrollUp: () => { Audio.speaker.volume += 0.025 },
            onScrollDown: () => { Audio.speaker.volume -= 0.025 },
            css: "font-size: 20px;",
            child: Widget.Box({
                children: [
                    Widget.Icon().hook(Audio.speaker, self => {
                        const vol = Audio.speaker.volume * 100;
                        let icon = [
                            [67, 'high'],
                            [1, 'low'],
                            [0, 'mute'],
                        ].find(([threshold]) => threshold <= vol)?.[1];
                        icon = Audio.speaker.is_muted ? "mute" : icon;
                        self.icon = `custom-audio-volume-${icon}-symbolic`;
                        self.tooltip_text = `Volume ${Math.floor(vol)}%`;
                        self.class_name = "icon"
                    }),
                    Widget.Label({
                        class_name: "value",
                        label: Audio.speaker.bind("volume").as(v => {
                            return `${Math.floor(v * 100).toString().padStart(2, '0')}`
                        }),
                    }),
                ]
            })
        }),

    ]
})

const AudioIndicator = () => Widget.Box({
    class_name: "audio",
    children: [
        VolumeIndicator(),
        MicrophoneIndicator()
    ]
})

export default AudioIndicator;

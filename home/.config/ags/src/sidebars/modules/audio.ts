import Audio from 'resource:///com/github/Aylur/ags/service/audio.js';
import Hyprland from 'resource:///com/github/Aylur/ags/service/hyprland.js';


App.addIcons(`${App.configDir}/assets`)

export enum Sink {
    Speaker = "speaker",
    Microphone = "microphone"
}

const iconSubstitute = (item: any, sink: Sink) => {
    const microphoneSubstitutes = {
        "audio-card-bluetooth": "custom-audio-item-headphones-symbolic",
        "audio-headphones-bluetooth": "custom-audio-item-headphones-symbolic",
        "audio-headset-analog-usb": "custom-audio-item-headphones-symbolic",
        "audio-headset-bluetooth": "custom-audio-item-headphones-symbolic",
        "audio-card-analog-usb": "audio-input-microphone-symbolic",
        "audio-card-analog-pci": "audio-input-microphone-symbolic",
        "audio-card-analog": "audio-input-microphone-symbolic",
        "camera-web-analog-usb": "camera-web-symbolic"
    };
    const speakerSubstitutes = {
        "audio-card-bluetooth": "custom-audio-item-headphones-symbolic",
        "audio-headphones-bluetooth": "custom-audio-item-headphones-symbolic",
        "audio-headset-bluetooth": "custom-audio-item-headphones-symbolic",
        "audio-card-analog-usb": "audio-speakers-symbolic",
        "audio-card-analog-pci": "audio-speakers-symbolic",
        "audio-card-analog": "audio-speakers-symbolic",
        "audio-headset-analog-usb": "custom-audio-item-headphones-symbolic",
    };

    switch (sink) {
        case Sink.Speaker:
            return speakerSubstitutes[item] || item;
        case Sink.Microphone:
            return microphoneSubstitutes[item] || item;
    }
};

const SinkItem = (sink: Sink) => stream => Widget.Button({
    on_clicked: () => Audio[sink] = stream,
    child: Widget.Box({
        class_name: "item",
        children: [
            Widget.Icon({
                class_name: "icon",
                icon: iconSubstitute(stream.icon_name, sink),
                tooltip_text: stream.icon_name,
            }),
            Widget.Label({
                class_name: "label",
                label: stream.description?.split(" ").slice(0, 4).join(" ").slice(0, 20)
            }),
            Widget.Box({ hexpand: true })
        ],
    }).hook(Audio, icon => {
        icon.class_name = Audio[sink].id === stream.id ? "item active" : "item inactive";
    }),
});

const Selector = (sink: Sink) => Widget.Box({
    class_name: "selector",
    vertical: true,
    children: [
        Widget.Box({ vertical: true })
            .hook(Audio, box => {
                box.children = Array
                    .from(Audio[sink + "s"].values())
                    .map(SinkItem(sink));
            }, "stream-added")
            .hook(Audio, box => {
                box.children = Array
                    .from(Audio[sink + "s"].values())
                    .map(SinkItem(sink));
            }, "stream-removed")
    ],
})

function ControlPanel(sink: Sink) {
    const Icon = () => Widget.Button({
        on_clicked: () => {
            Audio[sink].is_muted = !Audio[sink].is_muted;
        },
        on_secondary_click: () => {
            Utils.execAsync(`pavucontrol -t ${sink === Sink.Speaker ? 3 : 4}`)
        },
        child: Widget.Icon({
            icon: `${sink}-active-symbolic`,
            size: 20,
        }).hook(Audio, self => { self.icon = `${sink}-${Audio[sink].is_muted ? "muted" : "active"}-symbolic` }, "changed")
    })

    const ButtonRevealList = () => Widget.Button({
        child: Widget.Icon({
            icon: "button-arrow-down-symbolic",
            size: 16,
        }),
        onClicked: (self) => {
            DeviceList.reveal_child = !DeviceList.child_revealed;
            self.child.icon_name = `button-arrow-${DeviceList.reveal_child ? "up" : "down"}-symbolic`;
        }
    })

    const VolumeSlider = () => Widget.Slider({
        class_name: "volume",
        hexpand: true,
        draw_value: false,
        on_change: ({ value }) => {
            Audio[sink].volume = value;
        },
    }).hook(Audio, slider => {
        if (!Audio[sink]) return;

        slider.sensitive = Audio[sink]?.is_muted === null ? false : !Audio[sink]?.is_muted;
        slider.value = Audio[sink].volume;
    }, sink + "-changed");

    const DeviceList = Widget.Revealer({
        reveal_child: false,
        child: Selector(sink)
    })

    return Widget.Box({
        class_name: sink,
        vertical: true,
        children: [
            Widget.Box({
                class_name: "header",
                children: [
                    Icon(),
                    VolumeSlider(),
                    ButtonRevealList(),
                ]
            }),
            Widget.Box({
                class_name: "list",
                children: [
                    DeviceList
                ]
            })
        ]
    })
}

function AudioControl() {
    return Widget.Box({
        class_name: "audio-control",
        vertical: true,
        children: [
            ControlPanel(Sink.Speaker),
            ControlPanel(Sink.Microphone)
        ]
    })
}

export default AudioControl;
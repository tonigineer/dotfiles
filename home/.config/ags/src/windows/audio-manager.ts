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

const header = (sink: Sink) => Widget.Box({
    class_name: "header",
    children: [
        Widget.Icon({
            class_name: "icon",
            icon: `custom-audio-${sink}-symbolic`
        }),
        Widget.Box({ hexpand: true }),
        Widget.Label({
            class_name: "label",
            label: sink.charAt(0).toUpperCase() + sink.slice(1)
        }),
        Widget.Box({ hexpand: true }),
        Widget.Button({
            on_clicked: () => Utils.execAsync(`pavucontrol -t ${sink === Sink.Speaker ? 3 : 4}`)
                .catch(logError),
            child: Widget.Icon("custom-audio-settings-symbolic"),
        })
    ]
})

const sinkItem = (sink: Sink) => stream => Widget.Button({
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
                label: stream.description?.split(" ").slice(0, 4).join(" ")
            }),
        ],
    }).hook(Audio, icon => {
        icon.class_name = Audio[sink].id === stream.id ? "item active" : "item inactive";
    }),
});

const selector = (sink: Sink) => Widget.Box({
    class_name: "selector",
    vertical: true,
    children: [
        Widget.Box({ vertical: true })
            .hook(Audio, box => {
                box.children = Array
                    .from(Audio[sink + "s"].values())
                    .map(sinkItem(sink));
            }, "stream-added")
            .hook(Audio, box => {
                box.children = Array
                    .from(Audio[sink + "s"].values())
                    .map(sinkItem(sink));
            }, "stream-removed")
    ],
})

const panel = (sink: Sink) => Widget.Box({
    class_name: "panel",
    vertical: true,
    children: [
        header(sink),
        Widget.Separator({}),
        selector(sink)
    ]
})

const AudioManager = Widget.Window({
    class_name: "audio-manager",
    name: "audio-manager",
    monitor: Hyprland.active.bind("monitor").as(m => m.id),
    keymode: "exclusive",
    visible: false,
    anchor: ["top", "right"],
    layer: "overlay",
    margins: [15, 15],
    child: Widget.ListBox({
        setup(self) {
            self.add(panel(Sink.Speaker));
            self.add(panel(Sink.Microphone));
        }
    }),
    setup: self => self.keybind("Escape", () => {
        App.closeWindow("audio-manager")
    }),
});

export default AudioManager;
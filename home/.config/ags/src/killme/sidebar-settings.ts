import Hyprland from "resource:///com/github/Aylur/ags/service/hyprland.js";
import Audio from 'resource:///com/github/Aylur/ags/service/audio.js';
import Hypridle from "./../services/hypridle"


// --------------------------------------------------------------------------
// ------------------------------- CALENDAR ---------------------------------
// --------------------------------------------------------------------------
function Calendar() {
    const today = new Date();

    return Widget.Box({
        class_name: "calendar",
        child: Widget.Calendar({
            showDayNames: true,
            showDetails: false,
            showHeading: true,
            showWeekNumbers: true,
            day: today.getDate(),
            month: today.getMonth(),
            year: today.getFullYear(),
        })
    })
}

// --------------------------------------------------------------------------
// ----------------------------- SHUTDOWN MENU ------------------------------
// --------------------------------------------------------------------------
function ShutdownMenu() {
    const COMMANDS = {
        "shutdown": "systemctl poweroff",
        "reboot": "systemctl reboot",
        "hibernate": "systemctl hibernate",
        "suspend": "systemctl hybrid-sleep",
    }

    const ICONS = {
        "true": "󰤁",
        "false": "󰤂",
        "shutdown": "󰐥",
        "reboot": "󰜉",
        "suspend": "󱫟",
        "hibernate": "󱖐",
    }

    const reveal_child = Variable(false);

    const ShowButton = () => Widget.Button({
        class_name: "opener",
        label: reveal_child.bind().as(v => v ? "󰤁" : "󰤂"),
        cursor: "pointer",
        on_clicked: () => {
            reveal_child.value = !reveal_child.value;
        },
    })

    const Menu = () => Widget.Revealer({
        revealChild: reveal_child.bind(),
        transitionDuration: 1000,
        transition: 'slide_right',
        cursor: "pointer",
        child: Widget.Box({
            class_name: "menu",
            children:
                Object.keys(COMMANDS).map((k, v) => Widget.Button({
                    class_name: `${k}`,
                    label: ICONS[k],
                    cursor: "pointer",
                    on_clicked: () => {
                        reveal_child.value = !reveal_child.value;
                        Utils.execAsync(["bash", "-c", COMMANDS[k]]).catch(print);
                    },
                    tooltip_text: k.toUpperCase()
                }))
        }),
    })

    return Widget.Box({
        class_name: "shutdown-menu",
        children: [
            Menu(),
            Widget.Box({ hexpand: true }),
            ShowButton()]
    })
}

// --------------------------------------------------------------------------
// ----------------------------- QUICK SETTINGS -----------------------------
// --------------------------------------------------------------------------
function QuickSettings() {
    function changeDisplayLayout() {
        Hyprland.workspaces.filter(v => v.monitorID !== Hyprland.active.monitor.id)
            .forEach((w) => {
                Hyprland.messageAsync(`dispatch moveworkspacetomonitor ${w.id} ${Hyprland.active.monitor.name}`);
            })
        Hyprland.monitors.filter(v => v.id !== Hyprland.active.monitor.id)
            .forEach((m) => {
                Hyprland.messageAsync(`dispatch dpms ${m.dpmsStatus ? "off" : "on"} ${m.name}`);
            })
    }

    return Widget.Box({
        class_name: "quick-settings",
        vertical: true,
        children: [
            Widget.Box({
                children: [
                    Widget.Box({
                        class_name: "hypridle",
                        child: Widget.Button({
                            cursor: "pointer",
                            class_name: Hypridle.bind("is_active").as(v => v ? "active" : ""),
                            onPrimaryClick: () => { Hypridle.toggle(); },
                            child: Widget.Icon({
                                class_name: "icon",
                                icon: Hypridle.bind("is_active").as(v => `custom-hypridle-${v ? "enabled" : "disabled"}-symbolic`)
                            }),
                        }),
                    }),
                    Widget.Box({ hexpand: true }),
                    Widget.Box({
                        class_name: "display",
                        child:
                            Widget.Button({
                                class_name: Hyprland.bind("monitors").as(v => v.filter((m) => m.dpmsStatus).length > 1 ? "dual" : "single"),
                                cursor: "pointer",
                                onPrimaryClick: () => {
                                    changeDisplayLayout()
                                },
                                child: Widget.Icon({
                                    class_name: "icon",
                                    icon: Hyprland.bind("monitors")
                                        .as(v => `custom-monitors-${v.filter((m) => m.dpmsStatus).length > 1 ? "dual" : "single"}-symbolic`)
                                }),
                            })
                    })
                ]
            }),
        ]
    })
}

// --------------------------------------------------------------------------
// ----------------------------- VOLUME CONTROL -----------------------------
// --------------------------------------------------------------------------
function VolumeControl() {
    enum Sink {
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

    return Widget.Box({
        class_name: "audio-control",
        vertical: true,
        children: [
            Widget.Box({
                class_name: "speaker",
                children: [Widget.Box({
                    children: [selector(Sink.Speaker)]
                })]
            }),
            Widget.Box({
                class_name: "microphone",
                children: [Widget.Box({
                    children: [selector(Sink.Microphone)]
                })]
            })
        ]
    })
}

const BluetoothControl = () => Widget.Box({
    class_name: "bluetooth-control",
    children: [Widget.Label("dfas")]
})

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
    name: "sidebar-settings",
    monitor: Hyprland.active.bind("monitor").as(m => m.id),
    anchor: ["top", "right", "bottom", "right"],
    layer: "overlay",
    exclusivity: "exclusive",
    keymode: "on-demand",
    margins: [0, 0, 5, 5],
    visible: true,
    child: Widget.Box({
        vertical: true,
        children: [
            // Widget.Separator({
            //     vertical: true,
            //     css: "min-width: 10rem;"
            // }),

            ShutdownMenu(),
            Calendar(),
            QuickSettings(),
            VolumeControl(),
            BluetoothControl(),
            SessionInfo(),
            MediaControl()
        ]
    })
});

export default SidebarSettings;
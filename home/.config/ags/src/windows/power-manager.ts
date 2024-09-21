// import { NETWORK } from "./../index";
import Battery from 'resource:///com/github/Aylur/ags/service/battery.js';
import Hyprland from 'resource:///com/github/Aylur/ags/service/hyprland.js';
import PowerProfiles from 'resource:///com/github/Aylur/ags/service/powerprofiles.js';


const powerProfiles = () => Widget.CenterBox({
    class_name: "profiles",
    startWidget: Widget.Box({
        vertical: true,
        setup(self) {
            self.add(Widget.Box({
                children: [
                    Widget.Label({ label: "Power saver", class_name: "label" }),
                    Widget.Separator({ hexpand: true }),
                    Widget.Switch({ class_name: "switch" }).on("notify::active", ({ active }) => {
                        if (active) PowerProfiles.active_profile = "power-saver";
                    }).hook(PowerProfiles, self => self.active = PowerProfiles.active_profile === "power-saver")
                ]
            }));
            self.add(Widget.Box({
                children: [
                    Widget.Label({ label: "Balanced", class_name: "label" }),
                    Widget.Separator({ hexpand: true }),
                    Widget.Switch({ class_name: "switch" }).on("notify::active", ({ active }) => {
                        if (active) PowerProfiles.active_profile = "balanced";
                    }).hook(PowerProfiles, self => self.active = PowerProfiles.active_profile === "balanced")
                ]
            }));
            self.add(Widget.Box({
                children: [
                    Widget.Label({ label: "Performance", class_name: "label" }),
                    Widget.Separator({ hexpand: true }),
                    Widget.Switch({ class_name: "switch" }).on("notify::active", ({ active }) => {
                        if (active) PowerProfiles.active_profile = "performance";
                    }).hook(PowerProfiles, self => self.active = PowerProfiles.active_profile === "performance")
                ]
            }));
        }
    })

})

const batteryPercentage = () => Widget.CenterBox({
    spacing: 150,
    startWidget: Widget.Label({
        class_name: "label",
        hpack: "start",
        label: "Percent",
    }),
    endWidget: Widget.Label({
        class_name: "value",
        hpack: "end",
        label: Battery.bind("percent").as(v => `${v}`)
    })
})

const batteryTime = () => Widget.CenterBox({
    startWidget: Widget.Label({
        class_name: "label",
        hpack: "start",
        label: Battery.bind("charging")
            .as(v => v ? "Until fully charged" : "Time remaining")

    }),
    endWidget: Widget.Label({
        class_name: "value",
        hpack: "end",
        label: Battery.bind("time_remaining").as(v => `${(v / 60).toFixed(0)} min`)
    })
})


const consumption = () => Widget.CenterBox({
    startWidget: Widget.Label({
        class_name: "label",
        hpack: "start",
        label: Battery.bind("charging")
            .as(v => v ? "Power charge" : "Power usage")
    }),
    endWidget: Widget.Label({
        class_name: "value",
        hpack: "end",
        label: Battery.bind("energy_rate").as(v => `${v.toFixed(1)} W`)
    })
})

const battery = () => Widget.CenterBox({
    startWidget: Widget.Label({
        class_name: "label",
        hpack: "start",
        label: "Capacity"
    }),
    endWidget: Widget.Box({
        class_name: "value",
        hpack: "end",
        children: [
            Widget.Label({
                hpack: "end",
                label: Battery.bind("energy").as(v => `${v.toFixed(1)} / `)
            }),
            Widget.Label({
                hpack: "end",
                label: Battery.bind("energy_full").as(v => `${v.toFixed(1)} Wh`)
            })
        ]
    })
})

const PowerManager = Widget.Window({
    class_name: "power-manager",
    name: "power-manager",
    monitor: Hyprland.active.bind("monitor").as(m => m.id),
    anchor: ["top", "right"],
    layer: "overlay",
    margins: [15, 15],
    visible: false,
    child: Widget.Box({
        vertical: true,
        children: [
            Widget.Box({
                class_name: "infos",
                vertical: true,
                children: [
                    batteryPercentage(),
                    batteryTime(),
                    consumption(),
                    battery(),
                ]
            }),
            powerProfiles()
        ]
    })
});

export default PowerManager;
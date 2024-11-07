import Battery from 'resource:///com/github/Aylur/ags/service/battery.js';


function battery_label(): string {
    if (battery.charging || battery.charged) {
        return battery.percent >= 100 ? "" : `${battery.percent.toFixed()}`
    }
    const seconds = battery.time_remaining;
    return `${Math.floor(seconds / 3600)}h${Math.floor((seconds % 3600) / 60).toString().padStart(2, '0')}m`
}

function battery_tooltip(): string {
    return `Battery Stats

SOC \t\t ${battery.percent.toFixed()}
${battery.charging ? "Charging" : "Discharging"} \t ${battery.energy_rate.toFixed(1)} W

Capacity \t\t ${battery.energy.toFixed(1)} Wh
FullCapacity \t ${battery.energy_full.toFixed(1)} Wh`
}

const battery = await Service.import('battery')

function BatteryIndicator() {
    return Widget.Box({
        class_name: "battery",
        children: [
            Widget.Icon({
                icon: battery.bind('icon_name').as(v => { return v; }),
                size: 17
            }),
            Widget.Label({
                class_name: "label"
            }).hook(Battery, self => {
                self.label = battery_label();
                self.css = battery.charged ? "" : "margin-left: 0.5rem;"
                self.css = battery.percent < 15 ? "margin-left: 0.5rem; color: #FF6767;" : ""
            }, "changed")
        ],
        visible: battery.bind('available'),
        tooltip_text: ""
    }).hook(Battery, self => {
        self.tooltip_text = battery_tooltip();
    }, "changed")
}
export default BatteryIndicator;
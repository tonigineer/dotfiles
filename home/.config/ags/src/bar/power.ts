import Battery from 'resource:///com/github/Aylur/ags/service/battery.js';


const battPercentStr = () => {
    return `Percent\t\t\t${Battery.percent}`
}

const battTimeStr = () => {

    return Battery.charged
        ? "Fully charged" : "Remaining"
        + `\t\t${Battery.time_remaining === 0 ? "" : (Battery.time_remaining / 60).toFixed(0)} min`
}


const BatteryIndicator = () => Widget.Button({
    on_clicked: () => App.ToggleWindow("power-manager"),
    class_name: "battery",
    child: Widget.Icon({
        class_name: "icon",
        icon: Battery.bind('icon_name'),
        size: 15
    })
}).hook(Battery, self => {
    self.tooltip_text = `${battTimeStr()}\n${battPercentStr()}`
})


export default BatteryIndicator;
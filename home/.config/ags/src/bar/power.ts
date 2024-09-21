import Battery from 'resource:///com/github/Aylur/ags/service/battery.js';
import PowerProfiles from 'resource:///com/github/Aylur/ags/service/powerprofiles.js';


const battPercentStr = () => {
    return `Percent\t\t${Battery.percent}`
}

const battTimeStr = () => {
    return (Battery.charging
        ? "Full in\t\t" : "Remaining")
        + `${Battery.time_remaining === 0 ? "" : (Battery.time_remaining / 60).toFixed(0)} min`
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
    self.tooltip_text = `${battTimeStr()}
${battPercentStr()}

Mode\t\t${PowerProfiles.active_profile}`
})


export default BatteryIndicator;
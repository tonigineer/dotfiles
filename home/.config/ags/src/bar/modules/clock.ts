// import Hyprland from 'resource:///com/github/Aylur/ags/service/hyprland.js';


function Clock() {
    const timeStr = Variable("", {
        poll: [1000, 'date "+%H:%M"'],
    })

    const dateStr = Variable("", {
        poll: [10_0000, 'date "+%d.%m.%Y"'],
    })

    return Widget.Box({
        class_name: "clock",
        child: Widget.Button({
            // hpack: "end",
            // hexpand: false,
            class_name: "clock",
            child: Widget.Box({
                // vertical: true,
                children: [
                    Widget.Label({
                        class_name: "time",
                        hpack: "center",
                        label: timeStr.bind(),
                    }),
                    // Widget.Label({
                    //     class_name: "data",
                    //     hpack: "center",
                    //     label: dateStr.bind(),
                    // }),
                ]
            }),
            onClicked: () => {
                App.toggleWindow("SidebarSettings")
            }
        }),
        tooltip_text: dateStr.bind().as(v => "Date: " + v + "\n Toggle Settings Sidebar  ")
    })
}

export default Clock;
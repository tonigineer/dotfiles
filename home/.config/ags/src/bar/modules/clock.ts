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
            onClicked: () => { App.toggleWindow("sidebar-settings") }
        })
    })
}

export default Clock;
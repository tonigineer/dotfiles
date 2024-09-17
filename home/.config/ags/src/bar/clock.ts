const timeStr = Variable("", {
    poll: [1000, 'date "+%H:%M"'],
})
const dateStr = Variable("", {
    poll: [10_0000, 'date "+%d.%m.%Y"'],
})

const today = new Date();

const calendar = Widget.Calendar({
    showDayNames: true,
    showDetails: false,
    showHeading: true,
    showWeekNumbers: true,
    day: today.getDate(),
    month: today.getMonth(),
    year: today.getFullYear(),
});

const calendarPopup = Widget.Window({
    class_name: "calendar",
    name: "calendar",
    child: calendar,
    visible: false,
    layer: "overlay",
    anchor: ["top", "right"],
});

function Clock() {
    const timeWidget = Widget.Button({
        hpack: "end",
        hexpand: false,
        class_name: "clock",
        child: Widget.Box({
            vertical: true,
            children: [
                Widget.Label({
                    class_name: "time",
                    hpack: "center",
                    label: timeStr.bind(),
                }),

                Widget.Label({
                    class_name: "data",
                    hpack: "center",
                    label: dateStr.bind(),
                }),
            ]
        }),
        onHover() {
            calendarPopup.visible = true;
        },
        onHoverLost() {
            calendarPopup.visible = false;
        },
    });

    timeWidget.connect("leave-notify-event", (_, _event) => {
        calendarPopup.visible = false;
    });

    return timeWidget;
}

export default Clock;
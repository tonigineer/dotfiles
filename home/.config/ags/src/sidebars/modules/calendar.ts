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

export default Calendar;
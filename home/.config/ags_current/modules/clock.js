const dateStr = Variable("", {
    // poll: [1000, 'date "+%H:%M:%S %b %e."'],
    poll: [1000, 'date "+%H:%M"'],
})

export function Clock() {
    return Widget.Label({
        label: dateStr.bind(),
        class_name: "clock",
    })
}
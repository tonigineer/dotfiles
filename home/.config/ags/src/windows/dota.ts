
import Hyprland from 'resource:///com/github/Aylur/ags/service/hyprland.js';

const counter = Variable(-70);
const message = Variable(Widget);

const RUNES = {
    0: "Starting gold",
    120: "Water runes (1st)",
    240: "Water runes (2st)",
}

Utils.interval(50, async () => {
    // const v = counter.getValue();j
    if (!Dota.visible) {
        counter.setValue(-70);
        return
    }
    counter.setValue(counter.value + 1);


    // time.value = `${} : ${}`;
})

const font_size = 20;

function information(counter: number) {
    let info_labels = [
        Widget.Label({
            hexpand: true,
            hpack: "end",
            css: `color: red; font-weight: bold; font-size: ${font_size}px;`,
            label: `${Math.floor(Math.max(counter / 60, 0)).toFixed(0).padStart(2, "0")} : ${(counter % 60).toFixed(0).padStart(2, "0")}              `
        }),
    ]

    Object.keys(RUNES).forEach((k, v) => {
        let se = 15;
        // Staring phase
        if (counter <= 4.5 * 60) {
            if (counter >= parseInt(k) - se && counter < parseInt(k) + se) {
                info_labels.push(
                    Widget.Label({
                        hexpand: true,
                        hpack: "end",
                        css: `color: cyan; font-weight: bold; font-size: ${font_size}px;`,
                        label: `${RUNES[k]}`
                    })
                )
            }
        } else {
            se = 25;
            if (v == 0) {
                if ((counter + se) % (3 * 60) < se * 2) {
                    info_labels.push(
                        Widget.Label({
                            css: `color: orange; font-weight: bold; font-size: ${font_size}px;`,
                            label: `Gold runes`
                        })
                    )
                }
                if ((counter + se) % (2 * 60) < se * 2) {
                    info_labels.push(
                        Widget.Label({
                            css: `color: green; font-weight: bold; font-size: ${font_size}px;`,
                            label: `Bounty runes`
                        })
                    )
                }
                if ((counter + se) % (7 * 60) < se * 2) {
                    info_labels.push(
                        Widget.Label({
                            css: `color: blue; font-weight: bold; font-size: ${font_size}px;`,
                            label: `Wisdom runes`
                        })
                    )
                }
            }
        }
    })

    // if (counter > k) {
    //     info_labels.push()
    // }
    // return Widget.Label({
    //     label: "ss"
    // })

    if (info_labels.length > 1) info_labels = info_labels.slice(1)

    return info_labels;
}

const Dota = Widget.Window({
    name: "dota",
    monitor: Hyprland.active.bind("monitor").as(m => m.id),
    anchor: ["bottom", "left", "right"],
    layer: "overlay",
    margins: [290, 600],
    visible: false,
    css: "background: rgba(255, 255, 255, 0.05); border-radius: 10px;",
    // keymode: "exclusive",
    child: Widget.Box({
        vertical: true,
        hpack: "start",
        hexpand: true,
        // vexpand: true,
        children: counter.bind().as(counter => information(counter))
    }),
    setup: self => self.keybind("Delete", () => {
        // commandLine.children[1].text = "";
        App.closeWindow("dota")
    }),
})

export default Dota;
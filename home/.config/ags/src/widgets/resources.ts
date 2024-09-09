import { CONFIG } from "./../../config";

import { AnimatedCircProg } from "../utils/circular_progress.js";
import * as Utils from 'resource:///com/github/Aylur/ags/utils.js';
import { Int32 } from "types/@girs/freetype2-2.0/freetype2-2.0.cjs";


// Tool for stressing cpu
// yay -S xmrig
// xmrig --stress

const divide = ([total, free]) => free / total * 100

const cpu = Variable(0, {
    poll: [2000, 'top -b -n 1', out => divide([100, out.split('\n')
        .find(line => line.includes('Cpu(s)'))
        .split(/\s+/)[1]
        .replace(',', '.')])],
})

const BarResource = (id: string, icon: string, command: string, tooltip: string, poll_rate: Int32 = 1000) => {
    const resourceCircle = AnimatedCircProg({
        className: `resource ${id} circular`,
        vpack: 'center',
        hpack: 'center',
    });

    const resourceProgress = Widget.Box({
        homogeneous: true,
        children: [Widget.Overlay({
            child: Widget.Box({
                vpack: 'center',
                homogeneous: true,
                children: [
                    Widget.Label({
                        className: `resource ${id} icon`,
                        label: `${icon}`,
                    })
                ],
            }),
            overlays: [resourceCircle]
        })]
    });

    const resourceLabel = Widget.Label({
        className: `resource ${id} label`,
    });

    const widget = Widget.Button({
        onClicked: () => Utils.execAsync(id === "disc" ? `${CONFIG.apps.fileManager}` : `${CONFIG.apps.taskManager}`).catch(print),
        child: Widget.Box({
            className: `resource`,
            children: [
                resourceProgress,
                resourceLabel,
            ],
            setup: (self) => self.poll(poll_rate, () => Utils.execAsync(['bash', '-c', command])
                .then((output) => {
                    resourceCircle.css = `font-size: ${Number(output)}px;`;
                    resourceLabel.label = `${Math.round(Number(output))} `.padStart(4, "0");
                    widget.tooltipText = `${tooltip}   ${Math.round(Number(output))}`;
                }).catch(print))
            ,
        })
    });

    return widget;
}

const ResourceMonitor = () => Widget.Box({
    class_name: `resource`,
    children: [
        BarResource(
            'cpu',
            'C',
            `echo "$[100-$(vmstat 1 2|tail -1|awk '{print $15}')]"`,
            'CPU Usage',
            CONFIG.widgets.resources.poll_rates.cpu
        ),
        BarResource(
            'memory',
            'M',
            `LANG=C free | awk '/^Mem/ {printf("%.2f\\n", ($3/$2) * 100)}'`,
            'RAM Usage',
            CONFIG.widgets.resources.poll_rates.mem
        ),
        // LANG=C top -bn1 | grep Cpu | sed 's/\\,/\\./g' | awk '{print $2}'
        BarResource(
            'disc',
            'D',
            `df -h / --output=pcent | tail -n1 | cut -d"%" -f1 | awk '{printf("%.2f\\n", $1)}'`,
            'DISC Usage on /',
            CONFIG.widgets.resources.poll_rates.disc
        ),
        // TODO Using attributes would be better.
        //      https://aylur.github.io/ags-docs/config/widgets/#attribute-property
        Widget.Revealer({
            revealChild: false,
            transitionDuration: 1000,
            transition: 'slide_right',
            child: BarResource(
                'gpu',
                'G',
                `nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits`,
                'GPU Usage ',
                CONFIG.widgets.resources.poll_rates.gpu
            ),
            setup: self => self.poll(10000, () => Utils.execAsync(['bash', '-c', `nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits`])
                .then((output) => {
                    Number(output) > 15 ?
                        self.reveal_child = true :
                        self.reveal_child = false
                }).catch(print))
        }),
    ]
})

export { ResourceMonitor }
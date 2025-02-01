import { Variable, execAsync, bind } from "astal"
import { Astal, Gtk, Gdk } from "astal/gtk3"

import NetworkSpeed from "@services/NetworkSpeed"


export default function BarBottom(monitor: Gdk.Monitor) {
    const { BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor
    const network_speed = new NetworkSpeed()

    return <window
        className="BottomBar"
        gdkmonitor={monitor}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        anchor={BOTTOM | LEFT | RIGHT}>
        <centerbox>
            <box hexpand halign={Gtk.Align.START}>
            </box>
            <box
                className="NetworkSpeed">
                <label
                    css={bind(network_speed, "downloadSpeed")
                        .as(v => { if (v >= 0.1) { return "font-size: 14px;" } else { return "font-size: 14px; color: #232323;" } })
                    }
                    label={bind(network_speed, "downloadSpeed").as(v => `${v.toFixed(1).padStart(4)}`)} />
                <label
                    css={bind(network_speed, "downloadSpeed")
                        .as(v => { if (v >= 0.1) { return "color: rgba(255, 103, 103, 1);" } else { return "color: #232323;" } })
                    }
                    label=" ⇣ " />
                <label css="font-size: 10px; margin-top: 0.3rem;" label="Mb/s" />
                <label
                    css={bind(network_speed, "uploadSpeed")
                        .as(v => { if (v >= 0.1) { return "color: rgba(37, 201, 243, 1);" } else { return "color: #232323;" } })
                    }
                    label=" ⇡ " />
                <label
                    css={bind(network_speed, "uploadSpeed")
                        .as(v => { if (v >= 0.1) { return "" } else { return "color: #232323;" } })
                    }
                    label={bind(network_speed, "uploadSpeed").as(v => `${v.toFixed(1).padEnd(3)}`)} />
            </box>
            <box hexpand halign={Gtk.Align.END} >
            </box>
        </centerbox>
    </window >
}

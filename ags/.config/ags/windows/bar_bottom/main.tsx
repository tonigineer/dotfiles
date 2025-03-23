import { Astal, Gtk, Gdk } from "astal/gtk3"

import NetworkSpeeds from "@widgets/networkspeeds"
import Updates from "@widgets/updates"
import SystemStats from "@widgets/systemstats"


export default function BarBottom(monitor: Gdk.Monitor) {
    const { BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor

    return <window
        name="bar_bottom"
        className="bar_bottom"
        gdkmonitor={monitor}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        anchor={BOTTOM | LEFT | RIGHT}>
        <centerbox>
            <box hexpand halign={Gtk.Align.START}>
                <SystemStats />
                <Updates />
            </box>

            <box>
                <NetworkSpeeds />
            </box>
            <box hexpand halign={Gtk.Align.END} >
            </box>
        </centerbox>
    </window >
}

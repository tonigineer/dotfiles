import { Astal, Gtk, Gdk } from "astal/gtk3"

import NetworkSpeeds from "@widgets/networkspeeds"
import SystemStats from "@widgets/systemstats"
import { WidgetSystemUpdates } from "@windows/system/updates"


export default function BarBottom(monitor: Gdk.Monitor) {
    const { BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor

    return <window
        name="window_bar_bottom"
        className="BarBottom"
        gdkmonitor={monitor}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        anchor={BOTTOM | LEFT | RIGHT}>
        <centerbox>
            <box hexpand halign={Gtk.Align.START}>
                <SystemStats />
                <WidgetSystemUpdates />
            </box>
            <box>
                <NetworkSpeeds />
            </box>
            <box hexpand halign={Gtk.Align.END} >
            </box>
        </centerbox>
    </window >
}


import { Astal, Gtk, Gdk } from "astal/gtk3"

import { WidgetSystemStats } from "@components/system_statistics"
import { WidgetSystemUpdates } from "@components/system_updates"
import { WidgetNetworkStats } from "@components/network_statistics"
import { WidgetCava } from "@components/cava"
import { WidgetMedia } from "@components/media"

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
                <WidgetSystemStats />
                <WidgetSystemUpdates />
            </box>
            <box>
                <WidgetNetworkStats />
            </box>
            <box hexpand halign={Gtk.Align.END} >
                <WidgetCava />
                <WidgetMedia />
            </box>
        </centerbox>
    </window >
}


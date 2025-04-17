import { GLib } from "astal"
import { Astal, Gtk, Gdk } from "astal/gtk3"

import { WidgetHyprlandClient } from "@components/hyprland_client"
import { WidgetCava } from "@components/cava"
import { WidgetHyprlandWorkspaces } from "@components/hyprland_workspaces"
import { WidgetHypridle } from "@components/hypridle"
import { WidgetSpeaker } from "@components/speaker"
import { WidgetBattery } from "@components/battery"
import { WidgetSystemtray } from "@components/systemtray"
import { WidgetNetwork } from "@components/network_adapter"
import { WidgetClock } from "@components/clock"
import { WidgetShutdown } from "@components/shutdown"

export default function BarTop(monitor: Gdk.Monitor) {
    const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

    return <window
        name="window_bar_top"
        className="TopBar"
        gdkmonitor={monitor}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        anchor={TOP | LEFT | RIGHT
        }>
        <centerbox>
            <box>
                <icon
                    css="font-size: 18px;"
                    icon={GLib.get_os_info("LOGO") || "missing-symbolic"}
                />
                <WidgetHyprlandClient />
            </box>
            <box>
                <WidgetHyprlandWorkspaces monitor={monitor} />
            </box>
            <box hexpand halign={Gtk.Align.END}>
                <WidgetHypridle />
                <WidgetSpeaker />
                <WidgetBattery />
                <WidgetSystemtray />
                <WidgetNetwork />
                <WidgetClock />
                <WidgetShutdown />
            </box>
        </centerbox>
    </window >
}

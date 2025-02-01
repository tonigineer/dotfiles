import { GLib } from "astal"
import { Astal, Gtk, Gdk } from "astal/gtk3"

import Client from "@widgets/client"

import Workspaces from "@widgets/workspaces"

import Audio from "@widgets/audio"
import SystemTray from "@widgets/systemtray"
import Clock from "@widgets/clock"


export default function BarTop(monitor: Gdk.Monitor) {
    const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

    return <window
        className="TopBar"
        gdkmonitor={monitor}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        anchor={TOP | LEFT | RIGHT}>
        <centerbox>
            <box hexpand halign={Gtk.Align.START}>
                <icon
                    css="font-size: 18px;"
                    icon={GLib.get_os_info("LOGO") || "missing-symbolic"} />
                <Client />
            </box>
            <box>
                <Workspaces monitor={monitor} />
            </box>
            <box hexpand halign={Gtk.Align.END} >
                <Audio />
                <SystemTray />
                <Clock />
            </box>
        </centerbox>
    </window>
}

import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import { Variable, bind, exec, execAsync, GLib } from "astal"

import Tray from "gi://AstalTray"

import { Logger } from "@logging";

export function WidgetSystemtray() {
    const tray = Tray.get_default()

    return <box className="Tray">
        {bind(tray, "items").as(items => items.map((item: any) => (
            <menubutton
                tooltipMarkup={bind(item, "tooltipMarkup")}
                usePopover={false}
                actionGroup={bind(item, "actionGroup").as(ag => ["dbusmenu", ag])}
                menuModel={bind(item, "menuModel")}>
                <icon className="icon" gicon={bind(item, "gicon")} />
            </menubutton>
        )))}
    </box>
}


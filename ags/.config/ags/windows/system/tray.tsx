import { Variable, bind, exec, execAsync } from "astal"
import { App, Astal, Gtk, Gdk } from "astal/gtk3"

import Tray from "gi://AstalTray"

import { InteractiveWindow } from "@windows/templates"
import { Logger } from "@logging"

// const WINDOW_NAME = "window_tray";

export function WidgetTray() {
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

// function createContent() {
//
//     const example = Variable<string>("").poll(1000, () =>
//         exec([
//             "bash",
//             "-c",
//             "uptime -p | sed -e 's/up //;s/ hours,/h/;s/ hour,/h/;s/ minutes/m/;s/ minute/m/;s/ days,/d/;s/ day,/d/'"
//         ])
//     )
//
//     const current_selection = Variable(1);
//
//     const child = <box valign={Gtk.Align.CENTER} vertical>
//         <label label="Use j+k for navigation." className="hint" />
//     </box >
//
//     const keys = function(window: Gdk.Window, event: Gdk.Event) {
//
//         if (event.get_keyval()[1] === Gdk.KEY_Escape)
//             window.hide()
//     }
//
//     return { child, keys }
// }
//
// export function WindowShutdown() {
//     return InteractiveWindow(
//         WINDOW_NAME,
//         Astal.WindowAnchor.TOP | Astal.WindowAnchor.RIGHT,
//         createContent,
//         false
//     )
// }

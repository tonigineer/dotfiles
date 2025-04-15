import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import { Variable, bind, exec, execAsync, GLib } from "astal"

import { Logger } from "@logging";

export function WidgetClock({ format = "%H:%M" }) {
    const time = Variable<string>("").poll(1000, () =>
        GLib.DateTime.new_now_local().format(format)!)

    return <button
        className="Clock"
        tooltipMarkup={SHOW_TOOLTIPS ? GLib.DateTime.new_now_local().format("%A, %d. %B %Y")! : null}
        onClicked={() => { }}>
        <label label={time()} />
    </button >
}


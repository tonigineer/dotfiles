import { App, Astal, Gtk, Gdk } from "astal/gtk3";
import { Variable, bind, exec, execAsync, GLib } from "astal";

import { Logger } from "@logging";

export function WidgetMediaCtrl() {
    const dummy = (<label label="dymmy" css="color: orange;" />)

    return <box className="WidgetMediaCtrl">{dummy}</box>;
}



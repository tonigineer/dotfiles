import { Variable, GLib, bind } from "astal"
import { Astal, Gtk, Gdk } from "astal/gtk3"
import Client from "@widgets/client"

import { App } from "astal/gtk3";
export function PowerButton() {

    return <button onClicked={() => {
        const win = App.get_window("powermenu");
        if (win) {
            win.visible ? win.hide() : win.show();
        }
    }}>
        <label label="" css="font-size: 18px;" />
    </button>
}


export function PowerMenu(monitor: Gdk.Monitor) {
    const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

    return <window
        name="powermenu"
        className="TopBar2"
        gdkmonitor={monitor}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        anchor={TOP | RIGHT}
        application={App}>
        <box>
            <label label="test" css="color: red;" /></box>
    </window>
}

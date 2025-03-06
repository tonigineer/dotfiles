import { Variable, GLib, bind, exec, execAsync } from "astal"
import { Astal, Gtk, Gdk } from "astal/gtk3"
import Client from "@widgets/client"

import { App } from "astal/gtk3";
export function PowerButton() {

    return <button onClicked={() => {
        const win = App.get_window("shutdown");
        if (win) {
            win.visible ? win.hide() : win.show();
        }
    }}>
        <label label="" css="font-size: 18px;" />
    </button>
}


export function PowerMenu(monitor: Gdk.Monitor) {
    const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

    const powerActions = [
        { label: "", tooltip: "Shutdown", command: "poweroff" },
        { label: "", tooltip: "Reboot", command: "reboot" },
        { label: "", tooltip: "Suspend", command: "systemctl suspend" },
        { label: "", tooltip: "Hibernate", command: "systemctl hibernate" },
    ];


    return <window name="shutdown"
        className="shutdown"
        gdkmonitor={monitor}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        anchor={TOP | RIGHT}
        application={App}>
        <box className="container">
            {powerActions.map(({ label, tooltip, command }) => (
                <button className={command} onClicked={() =>
                    exec(["bash", "-c", command])
                }>
                    {label}
                </button>
            ))}
        </box>
    </window >
}


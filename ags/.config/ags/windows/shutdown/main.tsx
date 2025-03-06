import Client from "@widgets/client"

import { App } from "astal/gtk3";
import { Astal, Gtk, Gdk } from "astal/gtk3"
import { Variable, GLib, bind, exec, execAsync } from "astal"


export function ShutdownMenuButton() {
    return <button onClicked={() => {
        const win = App.get_window("shutdown_menu");
        if (win) {
            win.visible ? win.hide() : win.show();
        }
    }}>
        <label label="" css="font-size: 18px;" />
    </button>
}


export default function ShutdownMenu(monitor: Gdk.Monitor) {
    const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

    const powerActions = [
        { label: "", tooltip: "Shutdown", command: "poweroff" },
        { label: "", tooltip: "Reboot", command: "reboot" },
        { label: "", tooltip: "Suspend", command: "systemctl hybrid-sleep" },
        { label: "", tooltip: "Hibernate", command: "systemctl hibernate" },
    ];

    const stdout = exec(["bash", "-c", "uptime"]).trim().split(",").at(0).split(" ").filter(Boolean);

    let uptime_value, uptime_unit;

    if (stdout.length === 3) {
        uptime_value = stdout[2];
        uptime_unit = "h";
    } else {
        uptime_value = stdout[2];
        uptime_unit = stdout[3];
    }

    const current_selection = Variable(powerActions.length - 1);

    return <window name="shutdown_menu"
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        anchor={TOP | RIGHT}
        keymode={Astal.Keymode.ON_DEMAND}
        application={App}
        onShow={(self: any) => { }}
        onKeyPressEvent={function(self: any, event: Gdk.Event) {
            if (event.get_keyval()[1] === Gdk.KEY_Escape)
                self.hide()
            if (event.get_keyval()[1] === Gdk.KEY_j)
                current_selection.set((current_selection.get() - 1 + 4) % 4);
            if (event.get_keyval()[1] === Gdk.KEY_k)
                current_selection.set((current_selection.get() + 1) % 4);
            if (event.get_keyval()[1] === Gdk.KEY_ENTER)
                exec(["bash", "-c", powerActions[current_selection.get()].command]);
        }}>
        <box valign={Gtk.Align.CENTER} vertical >
            <box className="uptime" halign={Gtk.Align.CENTER}>
                <label label="Uptime" className="label" />
                <label label="   " />
                <label label={`${uptime_value} ${uptime_unit}`} className="value" />
            </box>
            <box className="buttons">
                {powerActions.map(({ label, tooltip, command }, index) => (
                    <button
                        className={bind(current_selection).as(v => v === index ? "selected" : "")}
                        onClicked={() =>
                            exec(["bash", "-c", command])
                        }>
                        <label label={label} />
                    </button>
                ))}
            </box>
        </box>
    </window >
}


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
        { label: "", command: "poweroff" },
        { label: "", command: "reboot" },
        { label: "", command: "loginctl lock-session; systemctl hybrid-sleep" },
        { label: "", command: "loginctl lock-session; systemctl hibernate" },
    ];

    const uptime_string = exec(["bash", "-c", "uptime -p | sed -e 's/up //;s/ hours,/h/;s/ hour,/h/;s/ minutes/m/;s/ minute/m/;s/ days,/d/;s/ day,/d/'"]);

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
        }}>
        <box valign={Gtk.Align.CENTER} vertical >
            <box className="uptime" halign={Gtk.Align.CENTER}>
                <label label="Uptime" className="label" />
                <label label="   " />
                <label label={`${uptime_string}`} className="value" />
            </box>
            <box className="buttons">
                {powerActions.map(({ label, }, index) => (
                    <button
                        className={bind(current_selection).as(v => v === index ? "selected" : "")}
                        onClicked={() =>
                            exec(["bash", "-c", `${powerActions[current_selection.get()].command}`])
                        }>
                        <label label={label} />
                    </button>
                ))}
            </box>
        </box>
    </window >
}


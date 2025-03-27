import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import { Variable, bind, exec, execAsync } from "astal"

import { Logger } from "@logging";
import { InteractiveWindow } from "@windows/templates"

const WINDOW_NAME = "window_shutdown";

export function WidgetShutdown() {
    return <button
        onClicked={() => {
            const win = App.get_window(WINDOW_NAME);
            if (win) {
                win.visible ? win.hide() : win.show();
            }
        }}>
        <label label="" css="font-size: 18px;" />
    </button>
}

function createContent() {
    const powerActions = [
        { label: "", command: "poweroff" },
        { label: "", command: "reboot" },
        { label: "", command: "loginctl lock-session; sleep 3; systemctl hybrid-sleep" },
        { label: "", command: "loginctl lock-session; sleep 3; systemctl hibernate" },
    ];

    const uptime = Variable<string>("").poll(1000, () =>
        exec([
            "bash",
            "-c",
            "uptime -p | sed -e 's/up //;s/ hours,/h/;s/ hour,/h/;s/ minutes/m/;s/ minute/m/;s/ days,/d/;s/ day,/d/'"
        ])
    )

    const current_selection = Variable(powerActions.length - 1);

    const child = <box valign={Gtk.Align.CENTER} vertical>
        <box className="uptime" halign={Gtk.Align.CENTER}>
            <label label="Uptime" className="label" />
            <label label="   " />
            <label label={uptime()} className="value" />
        </box>
        <box className="buttons">
            {powerActions.map(({ label, }, index) => (
                <button
                    className={bind(current_selection).as(v => v === index ? "selected" : "")}
                    onClicked={(async () => {
                        const action = powerActions[current_selection.get()].command;
                        Logger.info(`Execute shutdown command: ${action}`)
                        await execAsync(["bash", "-c", `ags toggle ${WINDOW_NAME}`])
                        await execAsync(["bash", "-c", action])
                    })}>
                    <label label={label} />
                </button>
            ))}
        </box>
        <label label="Use j+k for navigation." className="hint" />
    </box >

    const keys = function(window: Gdk.Window, event: Gdk.Event) {
        const num_actions = powerActions.length;

        if (event.get_keyval()[1] === Gdk.KEY_Escape)
            window.hide()
        if (event.get_keyval()[1] === Gdk.KEY_j)
            current_selection.set((current_selection.get() - 1 + num_actions) % num_actions);
        if (event.get_keyval()[1] === Gdk.KEY_k)
            current_selection.set((current_selection.get() + 1) % num_actions);
    }

    return { child, keys }
}

export function WindowShutdown() {
    return InteractiveWindow(
        WINDOW_NAME,
        Astal.WindowAnchor.TOP | Astal.WindowAnchor.RIGHT,
        createContent,
        false
    )
}

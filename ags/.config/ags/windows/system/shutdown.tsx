import { Variable, bind, exec, execAsync, GLib } from "astal"
import { App, Astal, Gtk, Gdk } from "astal/gtk3"

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

    async function getInstallDate(): Promise<string> {
        try {
            const output = await execAsync([
                "bash",
                "-c",
                "sudo stat /lost+found | grep 'Birth' || sudo stat / | grep 'Change'"
            ])

            const dateMatch = output.match(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/)
            if (!dateMatch) return "Unknown"

            const rawDate = dateMatch[0]
            const [dateStr] = rawDate.split(" ")
            const [year, month, day] = dateStr.split("-").map(Number)

            const installTime = GLib.DateTime.new_local(year, month, day, 0, 0, 0)
            const now = GLib.DateTime.new_now_local()

            const daysBetween = Math.floor(Math.abs(Number(now.difference(installTime)) / (1_000_000 * 60 * 60 * 24)))

            return `${day.toString().padStart(2, "0")}.${month
                .toString()
                .padStart(2, "0")}.${year}`
        } catch (e) {
            return `Failed to get date. ${e}`
        }
    }

    const installDate = Variable<string>("Fetching...").poll(1_000 * 60 * 60, getInstallDate)

    const current_selection = Variable(powerActions.length - 1);

    const child = <box valign={Gtk.Align.CENTER} vertical>
        <box className="uptime" halign={Gtk.Align.CENTER}>
            <label label="Uptime" className="label" />
            <label label=" " />
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
        <box className="birth" halign={Gtk.Align.CENTER}>
            <label label="Birth" className="label" />
            <label label=" " />
            <label label={installDate()} className="value" />
        </box>
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

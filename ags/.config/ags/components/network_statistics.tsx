import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import { Variable, bind, exec, execAsync, GLib } from "astal"

import { Logger } from "@logging";
import { InteractiveWindow } from "@windows/lib"

const WINDOW_NAME = "window_system_stats";

export function WidgetNetworkStats() {
    const service = SERVICES.NetworkStatistics;
    const active_min_mega_bytes = 0.05;

    return <button
        onClicked={() => {
            const win = App.get_window(WINDOW_NAME);
            if (win) {
                win.visible ? win.hide() : win.show();
            }
        }}>
        <box className="NetworkSpeeds">
            <label
                className={bind(service, "downloadSpeed").as(
                    v => { return `rx label ${v >= active_min_mega_bytes ? "active" : ""}` })}

                label={
                    bind(service, "downloadSpeed").as(
                        v => `${v.toFixed(1).padStart(4)}`
                    )
                }
            />
            <label
                className={bind(service, "downloadSpeed").as(
                    v => { return `rx icon ${v >= active_min_mega_bytes ? "active" : ""}` })}
                label=" ⇣ "
            />
            <label
                className="label"
                label="Mb/s"
            />
            <label
                className={bind(service, "uploadSpeed").as(
                    v => { return `tx icon ${v >= active_min_mega_bytes ? "active" : ""}` })}
                label=" ⇡ "
            />
            <label
                className={bind(service, "uploadSpeed").as(
                    v => { return `tx label ${v >= active_min_mega_bytes ? "active" : ""}` })}
                label={bind(service, "uploadSpeed").as(
                    v => `${v.toFixed(1).padEnd(3)}`
                )}
            />
        </box>    </button>
}

function createContent() {
    Logger.debug(`CreateContent called for window: ${WINDOW_NAME}`);

    const child = <box className="network-stats">
        <label css="font-size: 30px; color: red;" label="SYSTEM_STATS" />
    </box >

    const keys = function(window: Gdk.Window, event: Gdk.Event) {
        if (event.get_keyval()[1] === Gdk.KEY_Escape)
            window.hide()
    }

    return { child, keys }
}

export function WindowNetworkStats() {
    return InteractiveWindow(
        WINDOW_NAME,
        Astal.WindowAnchor.BOTTOM | Astal.WindowAnchor.CENTER,
        createContent,
        false
    )
}


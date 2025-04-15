import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import { Variable, bind, exec, execAsync, GLib } from "astal"

import Network from "gi://AstalNetwork"
import { Logger } from "@logging";
import { InteractiveWindow } from "@windows/lib"

const WINDOW_NAME = "window_network";

export function WidgetNetwork() {
    const network = Network.get_default()
    const wifi = bind(network, "wifi")
    const wired = bind(network, "wired")

    return <button
        onClicked={() => {
            const win = App.get_window(WINDOW_NAME);
            if (win) {
                win.visible ? win.hide() : win.show();
            }
        }}>
        <box visible={wired.as(Boolean)}>
            {wired.as(wired => wired && (
                <icon
                    tooltipText="wired"
                    className="Wired"
                    icon={bind(wired, "iconName")}
                />
            ))}
        </box>
        <box visible={wifi.as(Boolean)}>
            {wifi.as(wifi => wifi && (
                <icon
                    tooltipText={bind(wifi, "ssid").as(String)}
                    className="Wifi"
                    icon={bind(wifi, "iconName")}
                />
            ))}
        </box>
    </button>
}

function createContent() {
    Logger.debug(`CreateContent called for window: ${WINDOW_NAME}`);

    const child = <box className="network">
        <label css="font-size: 30px; color: red;" label="NETWORK" />
    </box >

    const keys = function(window: Gdk.Window, event: Gdk.Event) {
        if (event.get_keyval()[1] === Gdk.KEY_Escape)
            window.hide()
    }

    return { child, keys }
}

export function WindowNetwork() {
    return InteractiveWindow(
        WINDOW_NAME,
        Astal.WindowAnchor.TOP | Astal.WindowAnchor.RIGHT,
        createContent,
        false
    )
}



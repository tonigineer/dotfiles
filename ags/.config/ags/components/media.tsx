import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import { Variable, bind, exec, execAsync, GLib } from "astal"
import Mpris from "gi://AstalMpris"

import { Logger } from "@logging";
import { InteractiveWindow } from "@windows/lib"

const WINDOW_NAME = "window_media";

export function WidgetMedia() {
    const mpris = Mpris.get_default()

    return <box className="Media">
        {bind(mpris, "players").as(ps => ps[0] ? (
            <box>
                <box
                    className="Cover"
                    valign={Gtk.Align.CENTER}
                    css={bind(ps[0], "coverArt").as(cover =>
                        `background-image: url('${cover}');`
                    )}
                />
                <label
                    label={bind(ps[0], "metadata").as(() =>
                        `${ps[0].title} - ${ps[0].artist}`
                    )}
                />
            </box>
        ) : (
            <label label="Nothing Playing" />
        ))}
    </box>
}

function createContent() {
    Logger.debug(`CreateContent called for window: ${WINDOW_NAME}`);

    const child = <box className="media">
        <label css="font-size: 30px; color: red;" label="media" />
    </box >

    const keys = function(window: Gdk.Window, event: Gdk.Event) {
        if (event.get_keyval()[1] === Gdk.KEY_Escape)
            window.hide()
    }

    return { child, keys }
}

export function WindowMedia() {
    return InteractiveWindow(
        WINDOW_NAME,
        Astal.WindowAnchor.CENTER,
        createContent,
        true
    )
}



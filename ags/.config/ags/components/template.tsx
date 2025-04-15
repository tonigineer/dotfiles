import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import { Variable, bind, exec, execAsync, GLib } from "astal"

import { Logger } from "@logging";
import { InteractiveWindow } from "@windows/lib"

const WINDOW_NAME = "window_template";

export function WidgetTemplate() {
    return <button
        onClicked={() => {
            const win = App.get_window(WINDOW_NAME);
            if (win) {
                win.visible ? win.hide() : win.show();
            }
        }}>
        <label label="template" css="font-size: 14px; color: orange;" />
    </button>
}

function createContent() {
    Logger.debug(`CreateContent called for window: ${WINDOW_NAME}`);

    const child = <box className="template">
        <label css="font-size: 30px; color: red;" label="TEMPLATE" />
    </box >

    const keys = function(window: Gdk.Window, event: Gdk.Event) {
        if (event.get_keyval()[1] === Gdk.KEY_Escape)
            window.hide()
    }

    return { child, keys }
}

export function WindowTemplate() {
    return InteractiveWindow(
        WINDOW_NAME,
        Astal.WindowAnchor.CENTER,
        createContent,
        true
    )
}


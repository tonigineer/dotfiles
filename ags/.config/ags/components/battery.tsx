import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import { Variable, bind, exec, execAsync, GLib } from "astal"

import Battery from "gi://AstalBattery"
import { Logger } from "@logging";
import { InteractiveWindow } from "@windows/lib"

const WINDOW_NAME = "window_battery";

export function WidgetBattery() {
    const bat = Battery.get_default()

    return <button
        onClicked={() => {
            const win = App.get_window(WINDOW_NAME);
            if (win) {
                win.visible ? win.hide() : win.show();
            }
        }}>
        <box className="Battery"
            visible={bind(bat, "isPresent")}>
            <icon icon={bind(bat, "batteryIconName")} />
            <label label={bind(bat, "percentage").as(p =>
                `${Math.floor(p * 100)}`
            )} />
        </box>
    </button>
}

// function createContent() {
//     Logger.debug(`CreateContent called for window: ${WINDOW_NAME}`);
//
//     const child = <box className="battery">
//         <label css="font-size: 30px; color: red;" label="BATTERY" />
//     </box >
//
//     const keys = function(window: Gdk.Window, event: Gdk.Event) {
//         if (event.get_keyval()[1] === Gdk.KEY_Escape)
//             window.hide()
//     }
//
//     return { child, keys }
// }
//
// export function WindowBattery() {
//     return InteractiveWindow(
//         WINDOW_NAME,
//         Astal.WindowAnchor.CENTER,
//         createContent,
//         true
//     )
// }



import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import { Variable, bind, exec, execAsync } from "astal"

import { Logger } from "@logging";
import { InteractiveWindow } from "@windows/templates"

const WINDOW_NAME = "window_hypridle";

const hypridleIsRunning = Variable(false);

async function checkHypridleStatus() {
    try {
        const result = await exec(["bash", "-c", "pgrep hypridle"]);
        hypridleIsRunning.set(!isNaN(Number(result.trim())));
    } catch {
        hypridleIsRunning.set(false);
    }
}

async function toggleHypridle() {
    Logger.debug(`toggle hypridle called ${hypridleIsRunning.get()}`);
    if (hypridleIsRunning.get()) {
        Logger.debug("Hypridle running, kill it");
        await execAsync(["bash", "-c", "killall -9 hypridle"]);
    } else {
        Logger.debug("Start hypridle");
        const result = await execAsync(["bash", "-c", "killall -9 hypridle; hypridle"]);
        Logger.debug(result);
    }
}

checkHypridleStatus();
setInterval(checkHypridleStatus, 1000);

export function WidgetHypridle() {
    return <box className="Hypridle">
        <button
            onClicked={toggleHypridle}
            tooltipMarkup={!SHOW_TOOLTIPS ? null : bind(hypridleIsRunning).as(running => running ? "Hypridle is enabled" : "Hypridle is disabled")}
        >
            <label
                label={bind(hypridleIsRunning).as(running => running ? "󰒲" : "󰤄")}
                css="font-size: 18px;"
            />
        </button>
    </box >
}

// function createContent() {
//     const child = <box valign={Gtk.Align.CENTER} vertical>
//     </box >
//
//     const keys = function(window: Gdk.Window, event: Gdk.Event) {
//         if (event.get_keyval()[1] === Gdk.KEY_Escape)
//             window.hide()
//     }
//
//     return { child, keys }
// }

// export function WindowShutdown() {
//     return InteractiveWindow(
//         WINDOW_NAME,
//         Astal.WindowAnchor.TOP | Astal.WindowAnchor.RIGHT,
//         createContent,
//         true,
//         10000
//     )
// }


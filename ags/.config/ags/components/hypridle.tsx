import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import { Variable, bind, exec, execAsync, GLib } from "astal"

import { Logger } from "@logging";

const hypridleIsRunning = Variable(true);
checkHypridleStatus();
setInterval(checkHypridleStatus, 1000);

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

async function checkHypridleStatus() {
    try {
        const result = await exec(["bash", "-c", "pgrep hypridle"]);
        hypridleIsRunning.set(!isNaN(Number(result.trim())));
    } catch {
        hypridleIsRunning.set(false);
    }
}

export function WidgetHypridle() {
    return <box className="Hypridle">
        <button
            onClicked={toggleHypridle}
            tooltipMarkup={!SHOW_TOOLTIPS ? null : bind(hypridleIsRunning).as(running => running ? "Hypridle is enabled" : "Hypridle is disabled")}
        >
            <label
                label={bind(hypridleIsRunning).as(running => running ? "󰾪" : "󰤄")}
                css="font-size: 18px;"
            />
        </button>
    </box >
}


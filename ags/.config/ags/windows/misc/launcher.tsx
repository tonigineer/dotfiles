import { Variable, bind, exec, execAsync } from "astal"
import { App, Astal, Gtk, Gdk } from "astal/gtk3"

import Tray from "gi://AstalTray"

import { InteractiveWindow } from "@windows/templates"
import { Logger } from "@logging"

const wallpapers = Variable<string[]>([])

const WINDOW_NAME = "window_launcher";

function refreshWallpapers() {
    try {
        const stdout = exec(["bash", "-c", "find /home/$USER/.config/hypr/backgrounds -type f"]);
        const files = stdout.trim().split("\n").filter(Boolean);
        wallpapers.set(files);
        Logger.debug(`[Wallpapers] Updated: ${files.length} files`);
    } catch (err) {
        Logger.error(`Failed to find wallpapers: ${err}`);
    }
}

setInterval(refreshWallpapers, 2000);

function createContent() {

    refreshWallpapers();

    // bind(wallpapers).as(v => {
    //     Logger.debug(`Wallpapers updated to: ${v.length}`);
    //     // return Widget.Label({ label: `Wallpapers: ${v.length}` });
    // });


    const example = Variable<string>("").poll(1000, () =>
        exec([
            "bash",
            "-c",
            "uptime -p | sed -e 's/up //;s/ hours,/h/;s/ hour,/h/;s/ minutes/m/;s/ minute/m/;s/ days,/d/;s/ day,/d/'"
        ])
    )

    const current_selection = Variable(1);

    const child = <box valign={Gtk.Align.CENTER} vertical
        children=wallapers.map(file: any => {
            Widget.label = ({ label=file className="hint" })
        }
        ) >
    </box >

    const keys = function(window: Gdk.Window, event: Gdk.Event) {

        if (event.get_keyval()[1] === Gdk.KEY_Escape)
            window.hide()
    }

    return { child, keys }
}

export function WindowLauncher() {
    return InteractiveWindow(
        WINDOW_NAME,
        Astal.WindowAnchor.TOP | Astal.WindowAnchor.LEFT,
        createContent,
        true
    )
}



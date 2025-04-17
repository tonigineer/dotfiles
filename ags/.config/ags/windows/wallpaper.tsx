import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import { Variable, bind, exec, execAsync, GLib } from "astal"

import { Logger } from "@logging";
import { InteractiveWindow } from "@windows/lib"

import * as fs from "fs";
import * as path from "path";

const WINDOW_NAME = "window_wallpaper";

export function WidgetTemplate() {
    return <button
        onClicked={() => {
            const win = App.get_window(WINDOW_NAME);
            if (win) {
                win.visible ? win.hide() : win.show();
            }
        }}>
        <label label="wallpaper" css="font-size: 14px; color: orange;" />
    </button>
}

const wallpapers = Variable<string[]>([]);

const FetchWallpapers = async () => {
    await execAsync(["bash", "-c", "find /home/toni/.config/hypr/backgrounds -type f"]).then(
        output => wallpapers.set(output.trim().split("\n")));

    Logger.debug("!!!!!!!!!!!!!!!!!!!!!!!");
    wallpapers.get().forEach(v =>
        Logger.debug(v));
};


await FetchWallpapers();


const getWallpapers = () => {

    return wallpapers.get().map((v) => (

        <button
            valign={Gtk.Align.CENTER}
            css={`
          background-image: url("${v}");
    transition: all 0.5s;
    border: none;

    background-size: contain;
    background-position: center;
    background-repeat: no-repeat;

    min-width: 300px;
    min-height: 300px;
    border-radius: 25%;

    padding: 0px;
    margin: 0px;

        `}
            className="test"
            label={`1`}
            onClicked={(self) => {
            }}
            setup={(self) => {
            }}
        />
    ))
}


function createContent() {
    Logger.debug(`CreateContent called for window: ${WINDOW_NAME}`);

    const child = <box vertical className="main">
        <scrollable heightRequest={1024}>
            <box orientation={1}>
                {getWallpapers()}
            </box>
        </scrollable>
    </box >



    const keys = function(window: Gdk.Window, event: Gdk.Event) {
        if (event.get_keyval()[1] === Gdk.KEY_Escape)
            window.hide()
    }

    return { child, keys }
}

export function WindowWallpaper() {
    return InteractiveWindow(
        WINDOW_NAME,
        Astal.WindowAnchor.RIGHT | Astal.WindowAnchor.TOP | Astal.WindowAnchor.BOTTOM,
        createContent,
        true
    )
}



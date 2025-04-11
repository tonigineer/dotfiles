import { Variable, bind, exec, execAsync } from "astal"
import { App, Astal, Gtk, Gdk } from "astal/gtk3"

import Tray from "gi://AstalTray"

import { InteractiveWindow } from "@windows/templates"
import { Logger } from "@logging"

// const WINDOW_NAME = "window_wallpaper";

// export function WidgetWallpaper() {
//     const tray = Tray.get_default()
//
//     return <box className="Tray">
//         {bind(tray, "items").as(items => items.map((item: any) => (
//             <menubutton
//                 tooltipMarkup={bind(item, "tooltipMarkup")}
//                 usePopover={false}
//                 actionGroup={bind(item, "actionGroup").as(ag => ["dbusmenu", ag])}
//                 menuModel={bind(item, "menuModel")}>
//                 <icon className="icon" gicon={bind(item, "gicon")} />
//             </menubutton>
//         )))}
//     </box>
// }



export function WidgetWallpaper() {
    const tray = Tray.get_default()

    return <box className="Tray">
        {bind(tray, "items").as(items => items.map((item: any) => (
            <menubutton
                tooltipMarkup={bind(item, "tooltipMarkup")}
                usePopover={false}
                actionGroup={bind(item, "actionGroup").as(ag => ["dbusmenu", ag])}
                menuModel={bind(item, "menuModel")}>
                <icon className="icon" gicon={bind(item, "gicon")} />
            </menubutton>
        )))}

        {/* 🖼️ Wallpaper Picker Button */}
        <button tooltipMarkup="Choose wallpaper" onClicked={() => App.toggle_window("wallpaper_picker")}>
            <label label="🖼️" css="font-size: 16px;" />
        </button>
    </box>
}


async function createWallpaperPicker() {
    const wallpapers = Variable<string[]>([])


    wallpapers.set(["fdasf", "dfasf"]);

    Logger.debug(`!!!!!!!!!!!!!!!!!!!! ${wallpapers}`);

    // Load wallpapers from dir
    // exec(["bash", "-c", "find ~/.config/hypr/backgrounds -type f"])
    // .then(output => wallpapers.set(output.trim().split("\n")))


    // const stdout = exec(["bash", "-c", "find ~/.config/hypr/backgrounds -type f"]);
    await execAsync(["bash", "-c", "find ~/.config/hypr/backgrounds -type f"]).then(out => wallpapers.set(out.split("\n")));
    // wallpapers.set(stdout.split("\n"));
    Logger.debug(`!!!!!!!!!!!!!!!!!!!! ${wallpapers}`);
    // Logger.debug(`@!!!!!!!!!!!!!!!!!!!! ${out}`);

    bind(wallpapers).as(
        list => list.map(
            file => {
                Logger.debug("!!!!!!!!!!!!!!!!");
                Logger.debug(`f!!!!!! ${file}`);
            }));
    const child = <box> <label label="dfasfsafs" /></box>
    // const preview = Variable<string | null>(null)
    //
    // const child = <flow vertical homogeneous className="wallpaper-picker">
    //     {bind(wallpapers).as(list => list.map(file => (
    //         <button
    //             css={`margin: 4px; border - radius: 8px; `}
    //             tooltipMarkup={file}
    //             onClicked={() => {
    //                 preview.set(file)
    //                 execAsync(["hyprctl", "hyprpaper", "preload", file])
    //                 execAsync(["hyprctl", "hyprpaper", "wallpaper", `eDP - 1, ${ file } `]) // adjust monitor if needed
    //                 App.toggle_window("wallpaper_picker")
    //             }}
    //         >
    //             <img file={file} css="min-width: 200px; min-height: 120px;" />
    //         </button>
    //     )))}
    // </flow>

    const keys = (window: Gdk.Window, event: Gdk.Event) => {
        if (event.get_keyval()[1] === Gdk.KEY_Escape)
            window.hide()
    }

    return { child, keys }
}

export function WindowWallpaper() {
    return InteractiveWindow(
        "wallpaper_picker",
        Astal.WindowAnchor.FILL, // fullscreen
        createWallpaperPicker,
        true
    )
}




// function createContent() {
//
//     const example = Variable<string>("").poll(1000, () =>
//         exec([
//             "bash",
//             "-c",
//             "uptime -p | sed -e 's/up //;s/ hours,/h/;s/ hour,/h/;s/ minutes/m/;s/ minute/m/;s/ days,/d/;s/ day,/d/'"
//         ])
//     )
//
//     const current_selection = Variable(1);
//
//     const child = <box valign={Gtk.Align.CENTER} vertical>
//         <label label="Use j+k for navigation." className="hint" />
//     </box >
//
//     const keys = function(window: Gdk.Window, event: Gdk.Event) {
//
//         if (event.get_keyval()[1] === Gdk.KEY_Escape)
//             window.hide()
//     }
//
//     return { child, keys }
// }
//
// export function WindowShutdown() {
//     return InteractiveWindow(
//         WINDOW_NAME,
//         Astal.WindowAnchor.TOP | Astal.WindowAnchor.RIGHT,
//         createContent,
//         false
//     )
// }


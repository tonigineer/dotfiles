import { Variable, bind, exec, execAsync, GLib } from "astal"
import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import { timeout } from "astal/time"

import Wp from "gi://AstalWp"
import { Logger } from "@logging";
import { InteractiveWindow } from "@windows/lib"

const WINDOW_NAME = "window_speaker";

export function WidgetSpeaker() {
    const speaker = Wp.get_default()?.audio.defaultSpeaker!

    let hook_count = 0
    let visibility_toggle = Variable(false)

    // onClicked={() => {
    //     const win = App.get_window(WINDOW_NAME);
    //     if (win) {
    //         win.visible ? win.hide() : win.show();
    //     }
    // }}>
    return <box className="AudioSlider" >
        <button
            on_clicked={(_: any) => { visibility_toggle.set(!visibility_toggle.get()) }}>
            <icon icon={bind(speaker, "volumeIcon")} />
        </button>
        <revealer
            setup={(self: any) => {
                self.hook(speaker, "notify::volume", () => {
                    visibility_toggle.set(true);
                    hook_count++;
                    timeout(2000, () => { hook_count--; if (hook_count === 0) { visibility_toggle.set(false) } });
                });
            }}
            transitionType={Gtk.RevealerTransitionType.SLIDE_LEFT}
            transitionDuration={750}
            revealChild={visibility_toggle()}
        >
            <slider
                hexpand
                className={
                    bind(speaker, 'mute')
                        .as(isMute => isMute ?
                            'slider mute' : 'slider'
                        )
                }
                // cursor='pointer'
                // value={bind(speaker, 'volume')}
                max={1.5}
                step={0.05}
                // vexpand={true}
                // drawValue={false}
                // vertical={true}
                // inverted={true}
                onDragged={({ value }: { value: number }) => speaker.volume = value}
                value={bind(speaker, "volume")}
            />
        </revealer>
    </box >
}

function createContent() {
    const child = <box className="Speaker">
        <label css="font-size: 30px; color: red;" label="Speaker" />
    </box >

    const keys = function(window: Gdk.Window, event: Gdk.Event) {
        if (event.get_keyval()[1] === Gdk.KEY_Escape)
            window.hide()
    }

    return { child, keys }
}

export function WindowSpeaker() {
    return InteractiveWindow(
        WINDOW_NAME,
        Astal.WindowAnchor.TOP | Astal.WindowAnchor.RIGHT,
        createContent,
        false
    )
}


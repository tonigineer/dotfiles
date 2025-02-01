import { Variable, execAsync, bind } from "astal"
import { Gtk } from "astal/gtk3"
import { timeout } from "astal/time"

import Wp from "gi://AstalWp"


export default function Audio() {
    const speaker = Wp.get_default()?.audio.defaultSpeaker!

    let hook_count = 0
    let visibility_toggle = Variable(false)

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

                    // NOTE: Workaround for my Razor speaker! Fucking annoying :(
                    execAsync([
                        "bash",
                        "-c",
                        String.raw`pactl list sink-inputs | grep -oP '(?<=Sink Input #)\d+' | xargs -I{} pactl set-sink-input-volume {} ${speaker.volume * 100}%`
                    ]);
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

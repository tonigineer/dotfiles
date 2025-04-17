import { App, Astal, Gtk, Gdk } from "astal/gtk3";
import { Variable, bind, GLib } from "astal";

import { Logger } from "@logging";
import Cava from "gi://AstalCava";

const BAR_COUNT = 16;

const cava = Cava.get_default()!;
cava.set_bars(BAR_COUNT);

const BLOCKS = [
    "\u2581", "\u2582", "\u2583", "\u2584",
    "\u2585", "\u2586", "\u2587", "\u2588",
];
const BLOCKS_LENGTH = BLOCKS.length;
const EMPTY_BARS = "\u2581".repeat(BAR_COUNT);
const UPDATE_INTERVAL = 50;

const bars = Variable("");

export function WidgetCava() {
    let pendingUpdate = false;
    let lastValues: number[] | null = null;

    const updateBars = () => {
        if (!lastValues) return GLib.SOURCE_REMOVE;

        const rendered = lastValues
            .map(v => BLOCKS[Math.min(Math.floor(v * 8), BLOCKS_LENGTH - 1)])
            .join("");

        bars.set(rendered);
        revealer.reveal_child = rendered !== EMPTY_BARS;
        pendingUpdate = false;

        return GLib.SOURCE_REMOVE;
    };

    cava.connect("notify::values", () => {
        lastValues = cava.get_values();

        if (!pendingUpdate) {
            pendingUpdate = true;
            GLib.timeout_add(GLib.PRIORITY_DEFAULT, UPDATE_INTERVAL, updateBars);
        }
    });

    const revealer = (
        <revealer
            revealChild={false}
            transitionDuration={250}
            transitionType={Gtk.RevealerTransitionType.SLIDE_BOTTOM}
            child={
                <label
                    className="cava"
                    label={bind(bars)}
                    onDestroy={() => bars.drop()}
                />
            }
        />
    );

    return <box className="WidgetCava">{revealer}</box>;
}


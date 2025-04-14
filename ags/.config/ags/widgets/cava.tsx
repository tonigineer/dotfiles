import {
    bind,
    exec,
    GLib,
    Variable,
} from "../../../../../../../usr/share/astal/gjs";
import Cava from "gi://AstalCava";
const cava = Cava.get_default()!;


cava?.set_bars(12);
const bars = Variable("");
const blocks = [
    "\u2581",
    "\u2582",
    "\u2583",
    "\u2584",
    "\u2585",
    "\u2586",
    "\u2587",
    "\u2588",
];
// Assuming blocks is constant, move it outside
const BLOCKS_LENGTH = blocks.length;
const EMPTY_BARS = "".padEnd(12, "\u2581");



function AudioVisualizer() {
    const revealer = (
        <revealer
            revealChild={false}
            transitionDuration={globalTransition}
            transitionType={Gtk.RevealerTransitionType.SLIDE_LEFT}
            child={
                <label
                    className={"cava"}
                    onDestroy={() => bars.drop()}
                    label={bind(bars)}
                />
            }
        />
    );

    let pendingUpdate = false;
    let lastValues: any = null;
    const UPDATE_INTERVAL = 50; // ms

    cava?.connect("notify::values", () => {
        if (pendingUpdate) {
            lastValues = cava.get_values(); // Store latest values
            return;
        }

        pendingUpdate = true;
        lastValues = cava.get_values();

        GLib.timeout_add(GLib.PRIORITY_DEFAULT, UPDATE_INTERVAL, () => {
            const values = lastValues;
            const barArray = new Array(values.length);

            for (let i = 0; i < values.length; i++) {
                const val = values[i];
                const index = Math.min(Math.floor(val * 8), BLOCKS_LENGTH - 1);
                barArray[i] = blocks[index];
            }

            const b = barArray.join("");
            bars.set(b);
            revealer.reveal_child = b !== EMPTY_BARS;

            pendingUpdate = false;
            return GLib.SOURCE_REMOVE;
        });
    });

    return revealer;
}

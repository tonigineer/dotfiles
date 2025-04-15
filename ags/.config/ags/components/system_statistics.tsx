import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import { Variable, bind, exec, execAsync, GLib } from "astal"

import { Logger } from "@logging";
import { InteractiveWindow } from "@windows/lib"

const WINDOW_NAME = "window_system_stats";

export function WidgetSystemStats() {
    const getValueClass = (value: number) => {
        const rangeStart = Math.floor(value / 10) * 10;
        const rangeEnd = Math.min(rangeStart + 9, 99);
        return `label color-${rangeStart}-${rangeEnd}`;
    };

    const service = SERVICES.SystemStatistics;

    return <box className="SystemStats">
        <label
            className={bind(service, "cpuUsage").as((value: number) => getValueClass(value))}
            label={bind(service, "cpuUsage").as((value: number) => `${value.toFixed(0).padStart(3, ' ')}`)}
        />
        <label className="separator" label="" />
        <label className="icon" label="CPU" />

        <label
            className={bind(service, "ramUsage").as((value: number) => getValueClass(value))}
            label={bind(service, "ramUsage").as((value: number) => `${value.toFixed(0).padStart(3, ' ')}`)}
        />
        <label className="separator" label="" />
        <label className="icon" label="RAM" />


        {bind(service, "gpuUsage").as((value: number) =>
            value >= 0 ? (
                <>
                    <label
                        className={getValueClass(value)}
                        label={`${value.toFixed(0).padStart(3, ' ')}`}
                    />
                    <label className="separator" label="" />
                    <label className="icon" label="GPU" />
                </>
            ) : <box />
        )}

        <label
            className="label capacity"
            label={bind(service, "diskAvail").as((value: number) => `${value.toFixed(0).padStart(5, ' ')}Gb`)} />
        <label className="separator" label="" />
        <label className="icon" label="on /" />
    </box>
}

function createContent() {
    Logger.debug(`CreateContent called for window: ${WINDOW_NAME}`);

    const child = <box className="system-stats">
        <label css="font-size: 30px; color: red;" label="SYSTEM_STATS" />
    </box >

    const keys = function(window: Gdk.Window, event: Gdk.Event) {
        if (event.get_keyval()[1] === Gdk.KEY_Escape)
            window.hide()
    }

    return { child, keys }
}

export function WindowSystemStats() {
    return InteractiveWindow(
        WINDOW_NAME,
        Astal.WindowAnchor.BOTTOM | Astal.WindowAnchor.LEFT,
        createContent,
        false
    )
}


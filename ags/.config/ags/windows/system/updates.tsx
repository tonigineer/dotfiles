// @ts-nocheck

import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import { Variable, bind, exec, execAsync } from "astal"

import { Logger } from "@logging";
import { InteractiveWindow } from "@windows/templates"
import Cava from "gi://AstalCava"

import { SystemUpdates, keywordsMajorUpdates } from "@services/system_updates";

const WINDOW_NAME = "window_system_updates";
const service = SERVICES.SystemUpdates;

export function WidgetSystemUpdates() {
    return bind(service, "updatesCount").as((value: number) => value === 0 ? <box /> :
        <box className="Updates">
            <button onClicked={() => service.refresh()}><box>
                <label
                    className={bind(service, "hasMajorUpdates").as((flag: boolean) => flag ? "icon major" : "icon")}
                    label="" />
                <label
                    className="value"
                    label={bind(service, "updatesCount").as(String)}
                />
            </box>
            </button >
        </box>)
}

function createContent() {
    const child = bind(service, "stdout").as(
        (value: number) => {
            const allUpdates = service.stdout
                .trim()
                .split("\n")
                .map(line => line.trim())
                .filter(line => line.length > 0);

            const majorUpdates = allUpdates.filter(line =>
                keywordsMajorUpdates.some(keyword => line.toLowerCase().startsWith(keyword))
            );

            const remainingUpdates = allUpdates.filter(line =>
                !keywordsMajorUpdates.some(keyword => line.startsWith(keyword))
            );

            const hasUpdates = allUpdates.length > 0;
            const labelText = Variable(hasUpdates ? "Pending Updates" : "No Updates Available");

            return value === 0 ? <box /> :
                <box className="Updates" vertical spacing={8}>
                    <button
                        sensitive={hasUpdates}
                        onClicked={async () => {
                            await execAsync(["bash", "-c", "kitty -e yay -Syu"]);
                        }}
                        onEnterNotifyEvent={() => {
                            if (hasUpdates) labelText.set("Start updates");
                            return false;
                        }}
                        onLeaveNotifyEvent={() => {
                            if (hasUpdates) labelText.set("Pending updates");
                            return false;
                        }}
                    >
                        <label label={bind(labelText)} />
                    </button>

                    {hasUpdates && (

                        <>
                            <label label="Press SHIFT+U to update." className="hint" />
                            {majorUpdates.length > 0 && (
                                <>
                                    <box vertical spacing={4}>
                                        {majorUpdates.map(line => (
                                            <box>
                                                <label label={line} />
                                                <label label="⚠️" />
                                            </box>
                                        ))}
                                    </box>
                                </>
                            )}

                            {remainingUpdates.length > 0 && (
                                <>
                                    <box vertical spacing={4}>
                                        {remainingUpdates.map(line => (
                                            <box spacing={10} className="update_line">
                                                {line.split(" ").map(
                                                    (part, idx) =>
                                                        <label className={`part-${idx}`} label={part} halign={Gtk.Align.END} hexpand={true} />
                                                )}
                                            </box>
                                        ))}
                                    </box>
                                </>
                            )}
                        </>
                    )}
                </box>
        }
    );

    const keys = function(window: Gdk.Window, event: Gdk.Event) {

        if (event.get_keyval()[1] === Gdk.KEY_Escape)
            window.hide()
        if (event.get_keyval()[1] === Gdk.KEY_Escape)
            window.hide()
        if (event.get_keyval()[1] === Gdk.KEY_U) {
            execAsync(["bash", "-c", "kitty -e yay -Syu"]);
            window.hide();
        }
    }

    return { child, keys }
}

export function WindowSystemUpdates() {
    return InteractiveWindow(
        WINDOW_NAME,
        Astal.WindowAnchor.BOTTOM | Astal.WindowAnchor.LEFT,
        createContent
    )
}


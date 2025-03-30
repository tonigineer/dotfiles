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
    const actions: Record<number, () => void> = {
        1: () => {
            Logger.info("Left click detected!");
            const win = App.get_window(WINDOW_NAME);
            if (win) win.visible ? win.hide() : win.show();
        },
        3: () => {
            Logger.info("Right click detected!");
            service.refresh();
        },
    };

    // const button = event.get_button()[0];
    return bind(service, "updatesCount").as((value: number) => value === 0 ? <box /> :
        <box className="Updates">
            <button
                onButtonPressEvent={(self, event) => { actions[event.get_button()[1]]?.(); }}
            >
                <box>
                    <label
                        className={bind(service, "hasMajorUpdates").as((flag: boolean) => flag ? "icon major" : "icon")}
                        label="" />
                    <label
                        className="value"
                        label={bind(service, "updatesCount").as(String)} />
                </box>
            </button >
        </box >
    );
}

function createContent() {
    const child = bind(service, "stdout").as(
        (value: number) => {
            service.updatesCount > 0
            const allUpdates = service.stdout
                .trim()
                .split("\n")
                .map(line => line.trim())
                .filter(line => line.length > 0);

            const hasUpdates = service.updatesCount > 0;

            const majorUpdates = allUpdates.filter(line =>
                keywordsMajorUpdates.some(keyword => line.toLowerCase().startsWith(keyword))
            );

            const remainingUpdates = allUpdates.filter(line =>
                !keywordsMajorUpdates.some(keyword => line.startsWith(keyword))
            );

            const labelText = Variable(hasUpdates ? "Pending Updates" : "No Updates Available");

            const max_width_package = allUpdates
                .map(line => line.split(" ").at(0).length)
                .reduce((acc, x) => Math.max(acc, x), 0);
            Logger.debug(`Max length of all pacakges: ${max_width_package}`);

            const max_width_version = allUpdates
                .map(line => line.split(" ").at(1).length)
                .reduce((acc, x) => Math.max(acc, x), 0);
            Logger.debug(`Max length of all versions: ${max_width_version}`);

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

                    <Gtk.Separator visible />

                    {hasUpdates && (
                        <>
                            {majorUpdates.length > 0 && (
                                <>
                                    <box vertical spacing={4}>
                                        {majorUpdates.map(line => (
                                            <box spacing={10} className="update_line">
                                                {line.split(" ").map((part, idx) =>
                                                    <label
                                                        className={`part-${idx}${idx === 1 ? "-major" : ""}`}
                                                        xalign={0}
                                                        label={idx === 0 ? part.padEnd(max_width_package + 5, " ") :
                                                            idx === 1 ? part.padStart(max_width_version, " ") : part
                                                        }
                                                    />
                                                )}
                                            </box>
                                        ))}
                                    </box>
                                </>
                            )}

                            {remainingUpdates.length > 0 && (
                                <>
                                    <box vertical spacing={4} homogeneous={true}>
                                        {remainingUpdates.map(line => (
                                            <box spacing={10} className="update_line">
                                                {line.split(" ").map((part, idx) =>
                                                    <label
                                                        className={`part-${idx}`}
                                                        xalign={0}
                                                        label={idx === 0 ? part.padEnd(max_width_package + 5, " ") :
                                                            idx === 1 ? part.padStart(max_width_version, " ") : part
                                                        }
                                                    />
                                                )}
                                            </box>
                                        ))}
                                    </box>
                                </>
                            )}
                        </>
                    )}
                    <label label="Press SHIFT+U to update." className="hint" />
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


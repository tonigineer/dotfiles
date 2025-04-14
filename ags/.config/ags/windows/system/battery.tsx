import { bind } from "astal"
import { App, Astal, Gtk, Gdk } from "astal/gtk3"

import { Logger } from "@logging";



import Battery from "gi://AstalBattery";
const battery = Battery.get_default();


export function WidgetBattery() {
    const value = bind(battery, "percentage").as((p) => p);

    if (battery.percentage <= 0) return <box />;

    const label = (
        <label
            // className="icon"
            css="font-size: 30px;"
            label={bind(battery, "percentage").as((p) => {
                p *= 100;
                switch (true) {
                    case p == 100:
                        return "";
                    case p > 75:
                        return "";
                    case p > 50:
                        return "";
                    case p > 25:
                        return "";
                    case p > 10:
                        return "";
                    case p > 0:
                        return "";
                    default:
                        return "";
                }
            })}
        />
    );

    const info = (
        <label className={"icon"} label={value.as((v) => `${v * 100}%`)} />
    );



    return <box> {label} {info}</box>;
}

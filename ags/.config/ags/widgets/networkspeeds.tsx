// @ts-nocheck

import { bind } from "astal";
import NetSpeeds from "@services/NetSpeed";

export default function NetworkSpeeds() {
    const networkSpeed = new NetSpeeds();

    return (
        <box className="NetworkSpeeds">
            <label
                className={`value ${bind(networkSpeed, "downloadSpeed").as(
                    v => (v >= 0.1 ? "down" : "")
                )} `}
                label={bind(networkSpeed, "downloadSpeed").as(
                    v => `${v.toFixed(1).padStart(4)}`
                )}
            />
            <label
                className={bind(networkSpeed, "downloadSpeed").as(
                    v => (v >= 0.1 ? "down-icon-on" : "down-icon")
                )}
                label=" ⇣ "
            />
            <label
                className="label"
                label="Mb/s"
            />
            <label
                className={bind(networkSpeed, "uploadSpeed").as(
                    v => (v >= 0.1 ? "up-icon-on" : "up-icon")
                )}
                label=" ⇡ "
            />
            <label
                className={bind(networkSpeed, "uploadSpeed").as(
                    v => (v >= 0.1 ? "up-val-on" : "up-val")
                )}
                label={bind(networkSpeed, "uploadSpeed").as(
                    v => `${v.toFixed(1).padEnd(3)}`
                )}
            />
        </box>
    );
}


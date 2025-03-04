// @ts-nocheck

import { bind } from "astal";
import NetSpeeds from "@services/NetSpeed";

export default function NetworkSpeeds() {
    const networkSpeed = new NetSpeeds();
    const active_min_mega_bytes = 0.05;

    return (
        <box className="NetworkSpeeds">
            <label
                className={bind(networkSpeed, "downloadSpeed").as(
                    v => { return `rx label ${v >= active_min_mega_bytes ? "active" : ""}` })}

                label={
                    bind(networkSpeed, "downloadSpeed").as(
                        v => `${v.toFixed(1).padStart(4)}`
                    )
                }
            />
            <label
                className={bind(networkSpeed, "downloadSpeed").as(
                    v => { return `rx icon ${v >= active_min_mega_bytes ? "active" : ""}` })}
                label=" ⇣ "
            />
            <label
                className="label"
                label="Mb/s"
            />
            <label
                className={bind(networkSpeed, "uploadSpeed").as(
                    v => { return `tx icon ${v >= active_min_mega_bytes ? "active" : ""}` })}
                label=" ⇡ "
            />
            <label
                className={bind(networkSpeed, "uploadSpeed").as(
                    v => { return `tx label ${v >= active_min_mega_bytes ? "active" : ""}` })}
                label={bind(networkSpeed, "uploadSpeed").as(
                    v => `${v.toFixed(1).padEnd(3)}`
                )}
            />
        </box>
    );
}


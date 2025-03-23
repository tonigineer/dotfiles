// @ts-nocheck

import { bind } from "astal";

export default function NetworkSpeeds() {
    const service = SERVICES.NetworkStatistics;
    const active_min_mega_bytes = 0.05;

    return (
        <box className="NetworkSpeeds">
            <label
                className={bind(service, "downloadSpeed").as(
                    v => { return `rx label ${v >= active_min_mega_bytes ? "active" : ""}` })}

                label={
                    bind(service, "downloadSpeed").as(
                        v => `${v.toFixed(1).padStart(4)}`
                    )
                }
            />
            <label
                className={bind(service, "downloadSpeed").as(
                    v => { return `rx icon ${v >= active_min_mega_bytes ? "active" : ""}` })}
                label=" ⇣ "
            />
            <label
                className="label"
                label="Mb/s"
            />
            <label
                className={bind(service, "uploadSpeed").as(
                    v => { return `tx icon ${v >= active_min_mega_bytes ? "active" : ""}` })}
                label=" ⇡ "
            />
            <label
                className={bind(service, "uploadSpeed").as(
                    v => { return `tx label ${v >= active_min_mega_bytes ? "active" : ""}` })}
                label={bind(service, "uploadSpeed").as(
                    v => `${v.toFixed(1).padEnd(3)}`
                )}
            />
        </box>
    );
}


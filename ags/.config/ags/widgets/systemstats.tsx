// @ts-nocheck

import { bind } from "astal";
import SystemStats from "@services/SystemStats";

const getValueClass = (value: number) => {
    const rangeStart = Math.floor(value / 10) * 10;
    const rangeEnd = rangeStart + 9;
    return `label color-${rangeStart}-${rangeEnd}`;
};

export default function System() {
    const system = new SystemStats();

    return (
        <box className="SystemStats">
            <label
                className={bind(system, "cpuUsage").as((value: number) => getValueClass(value))}
                label={bind(system, "cpuUsage").as((value: number) => `${value.toFixed(0).padStart(3, ' ')}`)}
            />
            <label className="separator" label="" />
            <label className="icon" label="CPU" />

            <label
                className={bind(system, "ramUsage").as((value: number) => getValueClass(value))}
                label={bind(system, "ramUsage").as((value: number) => `${value.toFixed(0).padStart(3, ' ')}`)}
            />
            <label className="separator" label="" />
            <label className="icon" label="RAM" />


            {bind(system, "gpuUsage").as((value: number) =>
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
                label={bind(system, "diskAvail").as((value: number) => `${value.toFixed(0).padStart(5, ' ')}Gb`)} />
            <label className="separator" label="" />
            <label className="icon" label="on /" />
        </box>
    );
}

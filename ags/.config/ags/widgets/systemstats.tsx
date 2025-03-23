// @ts-nocheck

import { bind } from "astal";

const getValueClass = (value: number) => {
    const rangeStart = Math.floor(value / 10) * 10;
    const rangeEnd = Math.min(rangeStart + 9, 99);
    return `label color-${rangeStart}-${rangeEnd}`;
};

export default function System() {
    const service = SERVICES.SystemStatistics;

    return (
        <box className="SystemStats">
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
    );
}

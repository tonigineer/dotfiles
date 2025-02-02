// @ts-nocheck

import { bind } from "astal";
import SystemStats from "@services/SystemStats";

export default function System() {
    const system = new SystemStats();

    return (
        <box className="SystemStats">
            <icon className="icon" icon="gnome-panel-clock" />
            <label className="label" label={bind(system, "cpuUsage").as(String)} />
            <icon className="icon" icon="gnome-panel-clock" />
            <label className="label" label={bind(system, "ramUsage").as(String)} />
            <icon className="icon" icon="gnome-panel-clock" />
            <label className="label" label={bind(system, "discUsage").as(String)} />
            <icon className="icon" icon="gnome-panel-clock" />
            <label className="label" label={bind(system, "gpuUsage").as(String)} />
        </box>
    );
}

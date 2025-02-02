// @ts-nocheck

import { bind } from "astal";
import PackageUpdates from "@services/Update";

export default function Updates() {
    const updates = new PackageUpdates();

    return (
        <box className="Updates">
            <icon className="icon" icon="gnome-panel-clock" />
            <label
                className="value"
                label={bind(updates, "updatesCount").as(String)}
            />

        </box>
    );
}



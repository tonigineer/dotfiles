// @ts-nocheck

import { bind } from "astal";
import PackageUpdates from "@services/Update";

export default function Updates() {
    const updates = new PackageUpdates();

    return bind(updates, "updatesCount").as((value: number) => value === 0 ? <box /> :
        <box className="Updates">
            <button><box>
                <label
                    className={bind(updates, "isMajor").as((flag: boolean) => flag ? "icon major" : "icon")}
                    label="" />
                <label
                    className="value"
                    label={bind(updates, "updatesCount").as(String)}
                />
            </box>
            </button >
        </box>)
}

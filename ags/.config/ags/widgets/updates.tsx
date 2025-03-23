// @ts-nocheck

import { bind } from "astal";
import SystemUpdates from "@services/system_updates";

import { Logger } from "@logging";


export default function SystemUpdatesWidget() {
    const service = SERVICES.SystemUpdates;

    return bind(service, "updatesCount").as((value: number) => value === 0 ? <box /> :
        <box className="Updates">
            <button onClicked={() => service.refresh()}><box>
                <label
                    className={bind(service, "hasMajorUpdates").as((flag: boolean) => flag ? "icon major" : "icon")}
                    label="" />
                <label
                    className="value"
                    label={bind(service, "updatesCount").as(String)}
                />
            </box>
            </button >
        </box>)
}

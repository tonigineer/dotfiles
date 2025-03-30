import { exec } from "astal";

import SystemStatistics from "@services/system_statistics";
import NetworkStatistics from "@services/network_statistics";
import SystemUpdates from "@services/system_updates";

declare global {
    const USER: string;
    const HOME_DIR: string;
    const TMP: string;

    const SHOW_TOOLTIPS: boolean;

    const SERVICES: {
        NetworkStatistics: NetworkStatistics;
        SystemStatistics: SystemStatistics;
        SystemUpdates: SystemUpdates;
    };
}

const user = exec("whoami").trim();
const homeDir = exec("bash -c 'echo $HOME'").trim();

Object.assign(globalThis, {
    USER: user,
    HOME_DIR: homeDir,
    TMP: "/tmp",

    SHOW_TOOLTIPS: true,

    SERVICES: {
        NetworkStatistics: new NetworkStatistics({ updateRate: 500 }),
        SystemStatistics: new SystemStatistics({ pollInterval: 1000 }),
        SystemUpdates: new SystemUpdates({
            pollInterval: 3 * 60 * 1000,
            checkUpdatesCommand: "yay -Qus",
        }),
    },
});

export {};

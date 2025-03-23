import { exec } from "astal";

import NetworkStatistics from "@services/network_statistics";
import SystemStatistics from "@services/system_statistics";
import SystemUpdates from "@services/system_updates";

declare global {
    const USER: string;
    const HOME_DIR: string;
    const TMP: string;

    const CPU_POLL: number;
    const RAM_POLL: number;
    const DISKS_POLL: number;

    const ANIMATION_SPEED: number;

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

    CPU_POLL: 5000,
    RAM_POLL: 5000,
    DISKS_POLL: 600000,

    ANIMATION_SPEED: 100,

    SERVICES: {
        NetworkStatistics: new NetworkStatistics(),
        SystemStatistics: new SystemStatistics(),
        SystemUpdates: new SystemUpdates(),
    },
});

export {}; // Makes this a module so global augmentation works

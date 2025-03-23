import { execAsync, Gio, interval } from "astal";
import { GObject, register, property } from "astal/gobject";

import { Logger } from "@logging";

@register()
export default class SystemUpdates extends GObject.Object {
    declare private _pollInterval: number;

    @property(Number) declare updatesCount: number;
    @property(Boolean) declare hasMajorUpdates: boolean;

    constructor() {
        super();
        this._pollInterval = 3 * 60 * 1000; // 3 minutes
        this.updatesCount = 0;
        this.hasMajorUpdates = false;

        interval(this._pollInterval, () => this.refresh());
    }

    async refresh(): Promise<void> {
        try {
            const stdout = await execAsync(["bash", "-c", "yay -Qus"]);
            Logger.debug(stdout);

            const packages = stdout.trim().split("\n").filter(Boolean);
            this.updatesCount = packages.length;
            Logger.info(`Available updates: ${this.updatesCount}`);

            this.hasMajorUpdates = this.containsCriticalUpdates(packages);
            Logger.info(`Major updates pending: ${this.hasMajorUpdates}`);
        } catch (err: any) {
            if (err.matches || err.matches(Gio.IOErrorEnum)) {
                Logger.info("No updates are pending.");
                this.updatesCount = 0;
                this.hasMajorUpdates = false;
            } else {
                Logger.error(
                    `Failed to check system updates: ${err.toString()}`,
                );
                this.updatesCount = 1337;
                this.hasMajorUpdates = true;
            }
        }
    }

    private containsCriticalUpdates(lines: string[]): boolean {
        return lines.some(
            (line) =>
                line.startsWith("linux ") ||
                line.startsWith("nvidia ") ||
                line.startsWith("hyprland "),
        );
    }

    static get_default(): SystemUpdates {
        return new this();
    }

    public checkNow() {
        this.refresh();
    }
}

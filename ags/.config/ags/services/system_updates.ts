import { execAsync, Gio, interval } from "astal";
import { GObject, register, property } from "astal/gobject";

import { Logger } from "@logging";

export const keywordsMajorUpdates = ["linux", "hyprland", "nvidia"];

export interface Options {
    pollInterval?: number;
    checkUpdatesCommand?: string;
}

@register()
export default class SystemUpdates extends GObject.Object {
    declare private _pollInterval: number;
    declare private _checkUpdateCommand: string;

    @property(Number) declare updatesCount: number;
    @property(Boolean) declare hasMajorUpdates: boolean;
    @property(String) declare stdout: String;

    constructor(options: Options = {}) {
        super();
        this._pollInterval = options.pollInterval ?? 3 * 60 * 1000;
        this._checkUpdateCommand = options.checkUpdatesCommand ?? "yay -Qus";
        this.updatesCount = 0;
        this.hasMajorUpdates = false;
        this.stdout = "";

        interval(this._pollInterval, () => this.refresh());
    }

    async refresh(): Promise<void> {
        try {
            this.stdout = await execAsync(["bash", "-c", "yay -Sy"]);
            Logger.debug(
                `Fetch update info: ${this.stdout.split("\n").join("")}`,
            );

            this.stdout = await execAsync([
                "bash",
                "-c",
                this._checkUpdateCommand,
            ]);
            Logger.debug(`Update command: ${this.stdout.split("\n").join("")}`);

            const packages = this.stdout.trim().split("\n").filter(Boolean);
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
        return (
            lines.filter((line) =>
                keywordsMajorUpdates.some((keyword) =>
                    line.toLowerCase().startsWith(keyword),
                ),
            ).length > 0
        );
    }

    static get_default(): SystemUpdates {
        return new this();
    }

    public checkNow() {
        this.refresh();
    }
}

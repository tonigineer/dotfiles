import { GObject, register, property } from "astal/gobject";
import { execAsync, interval } from "astal";

import { Logger } from "@logging";

export interface Options {
    updateRate?: number;
}

@register()
export default class NetSpeed extends GObject.Object {
    declare private _prevRxBytes: number;
    declare private _prevTxBytes: number;
    declare private _updateRate: number;
    declare private _conversionFactor: number;

    @property(Number) declare downloadSpeed: number;
    @property(Number) declare uploadSpeed: number;

    constructor(options: Options = {}) {
        super();
        this._updateRate = options.updateRate ?? 500;
        this._conversionFactor = (this._updateRate / 1000) * 1e6; // Convert KB to Mb

        this.downloadSpeed = 0;
        this.uploadSpeed = 0;

        this.initializePreviousBytes().then(() => {
            interval(this._updateRate, () => this.updateSpeed());
        });
    }

    private async initializePreviousBytes(): Promise<void> {
        try {
            const { rxBytes, txBytes } = await this.getNetworkBytes();
            this._prevRxBytes = rxBytes;
            this._prevTxBytes = txBytes;
            Logger.debug(
                `Initial network speed - RX: ${this.downloadSpeed.toFixed(3).padStart(6, " ")} Mb/s | TX: ${this.uploadSpeed.toFixed(3).padStart(6, " ")}`,
            );
        } catch (error: any) {
            Logger.error(error.toString());
        }
    }

    private async getNetworkBytes(): Promise<{
        rxBytes: number;
        txBytes: number;
    }> {
        const stdout = await execAsync([
            "bash",
            "-c",
            "cat /sys/class/net/[ew]*/statistics/*_bytes",
        ]);

        // Logger.debug(`Network adpter bytes: ${stdout.split("\n").join()}`);

        const lines = stdout.split("\n").filter((line) => line.trim() !== "");
        const rxBytes = lines
            .filter((_, idx) => idx % 2 === 0)
            .reduce((sum, line) => sum + Number(line), 0);
        const txBytes = lines
            .filter((_, idx) => idx % 2 === 1)
            .reduce((sum, line) => sum + Number(line), 0);

        return { rxBytes, txBytes };
    }

    private async updateSpeed(): Promise<void> {
        try {
            const { rxBytes: newRxBytes, txBytes: newTxBytes } =
                await this.getNetworkBytes();
            this.downloadSpeed =
                (newRxBytes - this._prevRxBytes) / this._conversionFactor;
            this.uploadSpeed =
                (newTxBytes - this._prevTxBytes) / this._conversionFactor;

            this._prevRxBytes = newRxBytes;
            this._prevTxBytes = newTxBytes;
            Logger.debug(
                `Network speed - RX: ${this.downloadSpeed.toFixed(3).padStart(6, " ")} Mb/s | TX: ${this.uploadSpeed.toFixed(3).padStart(6, " ")}`,
            );
        } catch (error: any) {
            Logger.error(error.toString());
        }
    }

    static get_default(): NetSpeed {
        return new this();
    }
}

import { GObject, register, property } from "astal/gobject";
import { execAsync, interval } from "astal";

@register()
export default class NetSpeed extends GObject.Object {
    declare private _prevRxBytes: number;
    declare private _prevTxBytes: number;
    declare private _updateRate: number;
    declare private _conversionFactor: number;

    @property(Number) declare downloadSpeed: number;
    @property(Number) declare uploadSpeed: number;

    constructor() {
        super();
        this._updateRate = 1000; // ms
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
        } catch (error) {
            console.error("Error initializing network bytes:", error);
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
        } catch (error) {
            console.error("Error updating network speeds:", error);
        }
    }

    static get_default(): NetSpeed {
        return new this();
    }
}

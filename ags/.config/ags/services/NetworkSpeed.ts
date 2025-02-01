import { GObject, register, property } from "astal/gobject";
import { execAsync, interval } from "astal";

@register()
export default class NetworkSpeed extends GObject.Object {
    declare private _prevRxBytes: number;
    declare private _prevTxBytes: number;
    declare private _updateRate: number;
    declare private _conversionFactor: number;

    @property(Number) declare downloadSpeed: number;
    @property(Number) declare uploadSpeed: number;

    constructor() {
        super();
        this._updateRate = 500; // ms
        this._conversionFactor = (this._updateRate / 1000) * 1e6; // Update rate && KB to Mb

        this.downloadSpeed = 0;
        this.uploadSpeed = 0;

        this.initializePreviousBytes().then(() => {
            interval(this._updateRate, () => this.updateSpeed());
        });
    }

    private async initializePreviousBytes() {
        const { rxBytes, txBytes } = await this.getNetworkBytes();
        this._prevRxBytes = rxBytes;
        this._prevTxBytes = txBytes;
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

        let rxBytes = 0;
        let txBytes = 0;
        let idx = 0;

        for (const line of stdout.split("\n")) {
            if (idx % 2 === 0) {
                rxBytes += Number(line);
            } else {
                txBytes += Number(line);
            }
            idx++;
        }

        return { rxBytes, txBytes };
    }

    private async updateSpeed() {
        const { rxBytes: newRxBytes, txBytes: newTxBytes } =
            await this.getNetworkBytes();

        this.downloadSpeed =
            (newRxBytes - this._prevRxBytes) / this._conversionFactor;
        this.uploadSpeed =
            (newTxBytes - this._prevTxBytes) / this._conversionFactor;

        this._prevRxBytes = newRxBytes;
        this._prevTxBytes = newTxBytes;

        this.notify("downloadSpeed");
        this.notify("uploadSpeed");
    }

    static get_default(): NetworkSpeed {
        return new this();
    }
}

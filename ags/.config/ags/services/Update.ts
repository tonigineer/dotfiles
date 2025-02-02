import { GObject, register, property } from "astal/gobject";
import { execAsync, interval } from "astal";

@register()
export default class PackageUpdates extends GObject.Object {
    declare private _updateRate: number;

    @property(Number) declare updatesCount: number;

    constructor() {
        super();
        this._updateRate = 3 * 60 * 1000;
        this.updatesCount = 0;

        this.checkUpdates().then(() => {
            interval(this._updateRate, () => this.checkUpdates());
        });
    }

    private async checkUpdates(): Promise<void> {
        try {
            const stdout = await execAsync(["bash", "-c", "yay -Qyu | wc -l"]);
            this.updatesCount = parseInt(stdout.trim(), 10);
        } catch (error) {
            console.error("Error checking yay updates:", error);
        }
    }

    static get_default(): PackageUpdates {
        return new this();
    }
}

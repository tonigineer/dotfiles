import { GObject, register, property } from "astal/gobject";
import { exec, execAsync, interval } from "astal";

@register()
export default class PackageUpdates extends GObject.Object {
    declare private _updateRate: number;

    @property(Number) declare updatesCount: number;
    @property(Boolean) declare isMajor: boolean;

    constructor() {
        super();
        this._updateRate = 3 * 60 * 1000;
        this.updatesCount = 0;
        this.isMajor = false;

        this.checkUpdates().then(() => {
            interval(this._updateRate, () => this.checkUpdates());
        });
    }

    private async checkUpdates(): Promise<void> {
        try {
            const stdout = await execAsync([
                "bash",
                "-c",
                "yay -Sy >&/dev/null; yay -Qyu",
            ]);
            const lines = stdout.split("\n");
            console.log(lines);
            this.updatesCount = lines.length;
            this.isMajor = lines.some(
                (line: any) =>
                    line.startsWith("linux ") ||
                    line.startsWith("nvidia ") ||
                    line.startsWith("hyprland "),
            );
        } catch (error) {
            console.error("Error checking yay updates:", error);
        }
    }

    static get_default(): PackageUpdates {
        return new this();
    }
}

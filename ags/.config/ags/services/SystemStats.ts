import { GObject, register, property } from "astal/gobject";
import { execAsync, interval } from "astal";

@register()
export default class SystemStats extends GObject.Object {
    declare private _updateRate: number;

    @property(Number) declare cpuUsage: number;
    @property(Number) declare ramUsage: number;
    @property(Number) declare diskUsage: number;
    @property(Number) declare gpuUsage: number;

    constructor() {
        super();
        this._updateRate = 1000; // update every 1000ms

        this.cpuUsage = 0;
        this.ramUsage = 0;
        this.diskUsage = 0;
        this.gpuUsage = 0;

        this.initializeStats().then(() => {
            interval(this._updateRate, () => this.updateStats());
        });
    }

    private async initializeStats(): Promise<void> {
        try {
            await this.updateStats();
        } catch (error) {
            console.error("Error initializing system stats:", error);
        }
    }

    private async updateStats(): Promise<void> {
        try {
            // CPU usage: calculate as (100 - idle) using top command.
            const cpuOut = await execAsync([
                "bash",
                "-c",
                `top -bn1 | grep "Cpu(s)" | sed "s/.*, *\\([0-9.]*\\)%* id.*/\\1/" | awk '{print 100 - $1}'`,
            ]);
            this.cpuUsage = parseFloat(cpuOut.trim());

            // RAM usage: percentage used from free.
            const ramOut = await execAsync([
                "bash",
                "-c",
                `free | grep Mem | awk '{print $3/$2 * 100.0}'`,
            ]);
            this.ramUsage = parseFloat(ramOut.trim());

            // Disk usage: percentage used on root partition.
            const diskOut = await execAsync([
                "bash",
                "-c",
                `df / | tail -1 | awk '{print $5}' | sed 's/%//'`,
            ]);
            this.diskUsage = parseFloat(diskOut.trim());

            // GPU usage: using nvidia-smi (if available), else 0.
            try {
                const gpuOut = await execAsync([
                    "bash",
                    "-c",
                    `nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits`,
                ]);
                this.gpuUsage = parseFloat(gpuOut.trim());
            } catch (gpuErr) {
                this.gpuUsage = 0;
            }

            (GObject.Object.prototype as any).notify.call(this, "cpuUsage");
            (GObject.Object.prototype as any).notify.call(this, "ramUsage");
            (GObject.Object.prototype as any).notify.call(this, "diskUsage");
            (GObject.Object.prototype as any).notify.call(this, "gpuUsage");
        } catch (error) {
            console.error("Error updating system stats:", error);
        }
    }

    static get_default(): SystemStats {
        return new this();
    }
}

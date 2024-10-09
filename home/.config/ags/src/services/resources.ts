const POLL_RATES = {
    "cpu": 1000,
    "ram": 1000,
    "disk": 6 * 1000,
    "gpu": 1000,
}

const NVIDIA_GPU_PRESENT = !Utils
    .exec(["bash", "-c", "which nvidia-smi"]).includes("which:")


class Resources extends Service {
    static {
        Service.register(
            this,
            {},
            {
                ram: ["jsobject", "r"],
                cpu: ["jsobject", "r"],
                disk: ["jsobject", "r"],
                gpu: ["jsobject", "r"],
            },
        );
    }

    cpu = { widget_value: 0, tooltip_text: "" };
    ram = { widget_value: 0, tooltip_text: "" };
    disk = { widget_value: 0, tooltip_text: "" }
    gpu = { widget_value: 0, tooltip_text: "" }


    constructor() {
        super();
        Utils.interval(POLL_RATES.cpu, async () => {
            await this.refresh_cpu();
        });
        Utils.interval(POLL_RATES.ram, async () => {
            await this.refresh_ram();
        });
        Utils.interval(POLL_RATES.disk, async () => {
            await this.refresh_disk();
        });
        Utils.interval(POLL_RATES.gpu, async () => {
            if (NVIDIA_GPU_PRESENT)
                await this.refresh_gpu();
        });
    }

    async refresh_cpu() {
        try {
            const stdout = await Utils
                .execAsync(["bash", "-c", `echo "$[100-$(vmstat 1 2|tail -1|awk '{print $15}')]"`]);

            this.cpu = {
                widget_value: parseInt(stdout),
                tooltip_text: `CPU usage: ${parseInt(stdout)}`
            }

            this.changed("cpu");
        } catch (error) {
            console.error(error);
        }
    }

    async refresh_ram() {
        try {
            const stdout = await Utils.execAsync(["bash", "-c", `free --mebi | sed -n 2p`]);

            const [_label, total, used, free, _shared, _cache, _available] = stdout
                .split(/\s+/).map(v => parseInt(v));

            const usage = (used / total * 100)
            this.ram = {
                widget_value: usage,
                tooltip_text: `RAM usage: ${usage.toFixed(0)}\n${(used / 1000).toFixed(1)}/${(total / 1000).toFixed(1)} Gb`,
            };

            this.changed("ram");
        } catch (error) {
            console.error(error);
        }
    }

    async refresh_disk() {
        try {
            const stdout = await Utils.execAsync(["bash", "-c", `df -h`])

            const [part, size, used, _avail, usage, mount] = stdout
                .split("\n").filter(line => line.split(" ").slice(-1)[0] === "/")[0].split(/\s+/)

            this.disk = {
                widget_value: parseInt(usage),
                tooltip_text: `Disk usage:\t${parseInt(usage)}\t[${parseInt(used)}/${parseInt(size)} Gb]
'${part}' mounted on '${mount}'`
            }

            this.changed("disk");
        } catch (error) {
            console.error(error);
        }
    }

    async refresh_gpu() {
        try {
            const stdout = await Utils
                .execAsync(["bash", "-c", `nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits`])

            this.gpu = {
                widget_value: parseInt(stdout),
                tooltip_text: `GPU usage: ${parseInt(stdout)}`
            }

            this.changed("gpu");
        } catch (error) {
            console.error(error);
        }
    }

}

export default new Resources();

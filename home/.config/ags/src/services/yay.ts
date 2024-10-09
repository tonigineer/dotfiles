const POLL_RATE = 5 * 6 * 1000;

class Yay extends Service {
    static {
        Service.register(
            this,
            {},
            {
                updates: ["jsobject", "r"],
            },
        );
    }

    updates = { pending: 0, tooltip_text: "" };

    constructor() {
        super();
        Utils.interval(POLL_RATE, async () => {
            await this.refresh_updates();
        });
    }

    async refresh_updates() {
        try {
            const stdout = await Utils.execAsync(["bash", "-c", `yay -Sy>/dev/null 2>&1 && yay -Qu | sort`]);

            this.updates = {
                pending: stdout.split("\n").length,
                tooltip_text: `Pending updates:\n\n${stdout}`
            }

            this.changed("updates");
        } catch (error) {
            console.error(error);
        }
    }

}

export default new Yay();

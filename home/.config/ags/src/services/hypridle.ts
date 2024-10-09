class Hypridle extends Service {
    static {
        Service.register(
            this,
            {},
            {
                is_active: ["boolean", "r"],
            },
        );
    }

    is_active = false;

    constructor() {
        super();
        this.check_state();
    }

    async check_state() {
        this.is_active = Utils.exec(["bash", "-c", `pgrep hypridle`]) !== "";
    }

    async toggle() {
        Utils.execAsync(["bash", "-c", this.is_active ? `pkill hypridle` : `hypridle`]);
        this.is_active = !this.is_active;
        this.changed("is_active");
    }
}

export default new Hypridle();
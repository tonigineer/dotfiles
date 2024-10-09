export let CONFIG = {
    "apps": {
        "appLauncher": "rofi -show drun",
    },
    "widgets": {
        "launcher": {
        },
        "resources": {
            "poll_rates": {
                "cpu": 2_000,
                "ram": 5_000,
                "disk": 60_000,
                "gpu": 2_000,
            },
        },
        "updates": {
            "poll_rate": 300_00
        },
        "workspaces": {},
        "network": {
            "poll_rate": 500
        },
        "audio": {
            "showMicrophone": false,
            "showValues": true,
        },
    }
}

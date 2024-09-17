export let CONFIG = {
    "apps": {
        "taskManager": "kitty --title float -e btop",
        "fileManager": "kitty --title float -e yazi",
        "updater": "kitty --title float -e yay -Syu",
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
        "client": {
            "substitutions": {
                "steam_app_1086940": "Baldurs's Gate 3",
                "code-url-handler": "Visual Studio Code",
                "substitute": function substitute(key: string) {
                    if (key in CONFIG.widgets.client.substitutions) {
                        return CONFIG.widgets.client.substitutions[key]
                    }
                    return key;
                },
            },
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

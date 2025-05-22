import json
import os
from pathlib import Path

APPLICATION_NAME = "tgshell"

USERNAME = os.getlogin()
HOSTNAME = os.uname().nodename
# CACHE_DIR = str(GLib.get_user_cache_dir()) + f"/{APP_NAME}"
CONFIG_DIR = Path.home() / ".config" / "fabric"
CONFIG_FULLFILE = CONFIG_DIR / "config.json"

DEFAULT_CONFIG = {
    "windows": {
        "topbar": {
            "enabled": True,
            "icon-size": 28,
            "spacing": 4,
            "separator-width": "1rem"
        },
        "bottombar": {"enabled": True},
        "corners": {"enabled": True, "size": 45},
        # always, empty-only, hide
        "desktop-info": {"show": "empty-only"}
    },
    "widgets": {
        "clock": {"formats": ["%H:%M", "%d.%m.%Y  %H:%M"]},
        "workspaces": {
            "numbering": "arabic",
            "numberings": {
                "chinese": ["一", "二", "三", "四", "五", "六", "七", "八", "九", "〇"],
                "arabic":  ["1",  "2",  "3",  "4",  "5",  "6",  "7",  "8",  "9",  "0"],
                "roman":   ["I",  "II", "III","IV", "V", "VI", "VII","VIII","IX", "N"]
            },
            "monitor-specific": True,
            "window-icons": True
        }
    },
    "styles": {
        "monitor_dir": "src/styles",
        "compile_source": "src/styles/styles.scss",
        "compile_target": "src/styles.css"
    }
}


class Config:
    """Handles configuration loading and saving."""

    _config = None

    @classmethod
    def _load_config(cls) -> dict:
        try:
            with open(CONFIG_FULLFILE, "r") as file:
                return json.load(file)
        except (FileNotFoundError, json.decoder.JSONDecodeError):
            cls._save_config(DEFAULT_CONFIG)
            return DEFAULT_CONFIG

    @classmethod
    def get(cls) -> dict:
        if cls._config is None:
            cls._config = cls._load_config()
        return cls._config

    @classmethod
    def _save_config(cls, config: dict | None = None) -> None:
        with open(CONFIG_FULLFILE, "w") as file:
            json.dump(cls._config if config is None else config, file, indent=4)

    @classmethod
    def set(cls, config: dict):
        if cls._config is None:
            cls._config = cls._load_config()
        cls._config.update(config)
        cls._save_config()

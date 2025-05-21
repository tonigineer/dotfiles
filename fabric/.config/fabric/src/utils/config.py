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
            "icon-size": 24,
            "spacing": 4
        },
        "bottombar": {"enabled": True},
        "corners": {"enabled": True, "size": 100},
        # always, empty-only, hide
        "desktop-info": {"show": "hide"}
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

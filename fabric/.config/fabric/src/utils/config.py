from __future__ import annotations

import os
from enum import Enum
from pathlib import Path
from typing import ClassVar, Literal


class Config:
    """Fabric app configuration."""
    application_name: str = "tgshell"

    class General:
        """Basic runtime info."""
        username: str = os.getlogin()
        hostname: str = os.uname().nodename
        show_on: Literal["primary", "all"] = "all"

    class Paths:
        """Filesystem locations."""
        home_dir: Path = Path.home()
        config_dir: Path = home_dir / ".config" / "fabric"

    class Styles:
        """Style compilation paths."""
        monitor_dir: Path = Path("src/styles")
        compile_source: Path = Path("src/styles/styles.scss")
        compile_target: Path = Path("src/styles.css")

    class Windows:
        """Window-related UI."""

        class Topbar:
            """Top bar settings."""
            enabled: bool = True
            icon_size: int = 16
            spacing: int = 12
            separator_width: str = "1rem"

        class Bottombar:
            """Bottom bar settings."""
            enabled: bool = False

        class Corners:
            """Rounded corner size."""
            enabled: bool = True
            size: int = 45

        class DesktopInfo:
            """When to show desktop info."""
            enabled: bool = True
            show: Literal["always", "empty-only", "hide"] = "always"

            class Instruments(Enum):
                """Enum with keys for `system_stats` service.

                USAGE:
                    class Stats:
                        util_fabricator = Fabricator(poll_from=stats_poll, stream=True)
                        util_fabricator.connect("changed", self.update)

                        def update(self, _, values):
                            self.label1.set_label(f"{values.get(Instruments.memory)}")
                """
                cpu = "cpu_usage"
                memory = "ram_usage"
                gpu = "gpu"
                disk = "disk"
                disk_home = "disk_home"

            instruments: ClassVar = [
                Instruments.cpu,
                Instruments.memory,
                Instruments.memory,
                Instruments.disk,
                Instruments.disk_home
            ]

    class Widgets:
        """Individual widget defaults."""

        class Clock:
            """Clock formats."""
            formats: ClassVar = [
                "%H:%M",
                "%d.%m.%Y  %H:%M",
            ]

        class PowerMenuButton:
            icon: Path | str = Path("shutdown-symbolic")

            class Actions:
                class Lock:
                    name: str = "Lock"
                    cmd: str = "loginctl lock-session"
                    icon: str = "system-log-out"
                class Suspend:
                    name: str = "Supend"
                    cmd: str = "systemctl suspend"
                    icon: str = "system-suspend"
                class Hibernation:
                    name: str = "Hibernation"
                    cmd: str = "systemctl hibernate"
                    icon: str = "system-suspend-hibernate"
                class Restart:
                    name: str = "Restart"
                    cmd: str = "reboot"
                    icon: str = "system-reboot"
                class Shutdown:
                    name: str = "Shutdown"
                    cmd: str = "poweroff"
                    icon: str = "system-shutdown"

            class Overlay:
                timeout: int = 500
                transition_direction = "slide-down"
                transition_duration = 500

                class Actions:

                    class Shutdown:
                        icon: Path | str = Path("shutdown.svg")
                        cmd: str = "poweroff"
                    class Shutdow2n:
                        icon: Path | str = Path("shutdown.svg")
                        cmd: str = "poweroff"


        class Workspaces:
            """Workspace indicator settings."""
            numbering: Literal["chinese", "arabic", "roman"] = "arabic"
            numberings: ClassVar = {
                "chinese": ["一", "二", "三", "四", "五", "六", "七", "八", "九", "〇"],
                "arabic":  ["1",  "2",  "3",  "4",  "5",  "6",  "7",  "8",  "9",  "0"],
                "roman":   ["I",  "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "N"],
            }
            monitor_specific: bool = True
            window_icons: bool = True

        class SystemTray:
            monitor_id: int = 1
            svg_icon_map: ClassVar = {"steam": "steam-logo-white", "spotify": "spotify-logo"}

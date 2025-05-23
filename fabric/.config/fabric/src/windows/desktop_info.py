from __future__ import annotations

import json
from posix import kill

from fabric.hyprland.service import HyprlandEvent
from fabric.hyprland.widgets import get_hyprland_connection
from fabric.utils import bulk_connect
from fabric.widgets.box import Box
from fabric.widgets.datetime import DateTime
from fabric.widgets.label import Label
from fabric.widgets.wayland import WaylandWindow as Window
from loguru import logger

from src.utils.config import Config
from src.utils.system_stats import util_fabricator
from src.utils.types import Anchor, Layer
from src.widgets.misc import Separator


class CategoryLabel(Box):
    """Widget to put two labels next to each other as `CATEGORY  Content`."""
    def __init__(self, category: str, content: str, **kwargs):
        super().__init__(**kwargs)

        self.children=[
            Label(name="category", label=category),
            Label(name="content", label=content)
        ]

# BAR_STYLES: dict[str, list[str]] = {
#     "blocks":      ["█", "░"],
#     "half_blocks": ["█", "▁"],
#     "shades":      ["▓", "░"],
#     "dots":        ["●", "·"],
#     "squares":     ["■", "□"],
#     "thin":        ["▉", "▏"],
#     "braille":     ["⣿", "⠀"],
#     "emoji":       ["🔋", "🟥"],
# }

def bar_from_percent(percent: float, width: int = 8,
    filled_char: str = "⣿", empty_char: str = "⠀"
) -> str:
    """Return a simple text bar like: [ ███░░░ ]."""

    percent = max(0, min(100, percent))        # clamp
    filled  = int(percent * width / 100)
    empty   = width - filled
    bar     = filled_char * filled + empty_char * empty
    return f"[ {bar} ]"


class DesktopInfo(Window):
    """A simple desktop clock widget."""

    def __init__(self,
        date_format: str,
        anchor: Anchor = "bottom-right",
        layer: Layer = "background",
        **kwargs
    ):
        self.system_info_widget = self.system_info(None)

        super().__init__(
            name="desktop-info",
            layer=layer,
            anchor=anchor,
            child=Box(
                name="desktop-info-container",
                orientation="v",
                children=[
                    DateTime(formatters=["%H:%M"], name="clock"),
                    DateTime(formatters=[date_format], interval=10000, name="date"),
                    Separator(style="min-height: 2rem;"),
                    self.system_info_widget
                ],
            ),
            all_visible=True,
            **kwargs,
        )

        if Config.Windows.DesktopInfo.show == "hide":
            self.hide()
            return

        util_fabricator.connect("changed", self.update_system_info)

        if Config.Windows.DesktopInfo.show == "always":
            return

        self.connection = get_hyprland_connection()
        bulk_connect(self.connection, {
            "event::workspace": self.get_window_count,
            "event::focusedmon": self.get_window_count,
            "event::openwindow": self.get_window_count,
            "event::closewindow": self.get_window_count,
            "event::movewindow": self.get_window_count,
        })

        if self.connection.ready:
            self.on_ready(None)
        else:
            self.connection.connect("event::ready", self.on_ready)

    def update_system_info(self, _, values):
        self.system_info_widget.children = [self.system_info(values)]

    def system_info(self, values: dict | None) -> Box:
        if values is None:
            return Box()

        return Box(name="system-info", h_align="center", orientation="vertical", spacing=8, children=[
            Box(h_align="center", orientation="h", spacing=25,
                children=[
                    CategoryLabel("NAME:", Config.General.hostname, spacing=8),
                    CategoryLabel("KERNEL:", values.get("kernel", ""), spacing=8),
                ]
            ),
            Box(h_align="center", orientation="h", spacing=25,
                children=[
                    CategoryLabel("DATE_TIME:", values.get("datetime", "NA"), spacing=8),
                    CategoryLabel("UP_TIME:", values.get("uptime", "NA"), spacing=8),
                ]
            ),
            Box(h_align="center", orientation="h", spacing=25,
                children=[
                    CategoryLabel("CPU:", f"{bar_from_percent(values.get("cpu_usage", 100))}", spacing=8),
                    CategoryLabel("MEM:", f"{bar_from_percent(values.get("ram_usage", 100))}", spacing=8),
                    CategoryLabel("GPU:", f"{bar_from_percent(values.get("gpu_usage", 100))}", spacing=8),

                ]
            ),
            Box(h_align="center", orientation="h", spacing=25,
                children=[
                    CategoryLabel("CPU_TEMP:", f"{values.get("cpu_temp", 100):0.1f} 󰔄", spacing=8),
                    CategoryLabel("GPU_TEMP:", f"{values.get("gpu_temp", 100):0.1f} 󰔄", spacing=8),
                ]
            ),
            Box(h_align="center", orientation="h", spacing=25,
                children=[
                    CategoryLabel("/", f"{bar_from_percent(values.get("disk", 100))}", spacing=8),
                    CategoryLabel(str(Config.Paths.home_dir), f"{bar_from_percent(values.get("disk_home", 100))}", spacing=8),
                    CategoryLabel("SWAP", f"{bar_from_percent(values.get("disk_swap", 100))}", spacing=8),
                ]
            ),
            Box(h_align="center", orientation="h", spacing=25,
                children=[
                    CategoryLabel("fabricCORE", f"{values.get("app_cpu", 100)} 󰏰", spacing=8),
                    CategoryLabel("fabricMEM", f"{values.get("app_memory", 100)} MiB", spacing=8),
                ]
            ),
        ])

    def on_ready(self, _):
        return self.get_window_count(None, _), logger.info(
            "[WindowCount] Connected to the hyprland socket"
        )

    def get_window_count(self, _, event: HyprlandEvent):
        """Get the number of windows in the active workspace."""
        monitors = json.loads(str(
            self.connection.send_command("j/monitors").reply.decode()
        ))
        workspaces = json.loads(str(
            self.connection.send_command("j/workspaces").reply.decode()
        ))

        monitor = next((m for m in monitors if m["id"] == self.monitor), None)
        if monitor is None:
            logger.warning(f"No monitor for ID {self.monitor} found in j/monitors")
            return

        active_ws_id = monitor["activeWorkspace"]["id"]

        active_ws = next(
            (w for w in workspaces
             if w["id"] == active_ws_id and w["monitorID"] == self.monitor),
            None,
        )
        if active_ws is None:
            logger.warning(f"No active workspace found with ID {active_ws_id}")
            return

        self.set_visible(True) if active_ws["windows"] == 0 else self.set_visible(False)

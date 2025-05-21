import json

from fabric.hyprland.service import HyprlandEvent
from fabric.hyprland.widgets import get_hyprland_connection
from fabric.utils import bulk_connect
from fabric.widgets.box import Box
from fabric.widgets.datetime import DateTime
from fabric.widgets.wayland import WaylandWindow as Window
from loguru import logger

from src.utils.config import Config
from src.utils.types import Anchor, Layer

# TODO: check in config.py
# TODO: make config a class
cfg = Config.get()["windows"]["desktop-info"]

if cfg["show"] not in ["always", "empty-only", "hide"]:
    logger.error(
        f'Value `{cfg["show"]}` not correct for ["windows"]["desktop-info"]["show"]'
    )
    config_show = "hide"


class DesktopClock(Window):
    """A simple desktop clock widget."""

    def __init__(self,
        date_format: str,
        anchor: Anchor = "bottom-right",
        layer: Layer = "background",
        **kwargs
    ):
        super().__init__(
            name="desktop-info",
            layer=layer,
            anchor=anchor,
            child=Box(
                name="desktop-clock-box",
                orientation="v",
                children=[
                    DateTime(formatters=["%H:%M"], name="clock"),
                    DateTime(formatters=[date_format], interval=10000, name="date"),
                ],
            ),
            all_visible=True,
            **kwargs,
        )

        if cfg["show"] == "hide":
            self.hide()
            return

        if cfg["show"] == "always":
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

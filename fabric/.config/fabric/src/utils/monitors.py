import json
from typing import Dict

from fabric.hyprland import Hyprland
from gi.repository import Gdk


class HyprlandWithMonitors(Hyprland):
    """A Hyprland class with additional monitor common."""

    _instance = None

    @staticmethod
    def get_default():
        if HyprlandWithMonitors._instance is None:
            HyprlandWithMonitors._instance = HyprlandWithMonitors()

        return HyprlandWithMonitors._instance

    def __init__(self, commands_only: bool = False, **kwargs):
        self.display: Gdk.Display = Gdk.Display.get_default()
        super().__init__(commands_only, **kwargs)

    def get_all_monitors(self) -> dict[str, str]:
        monitors = json.loads(self.send_command("j/monitors").reply)
        return {monitor["id"]: monitor["name"] for monitor in monitors}

    def get_gdk_monitor_id_from_name(self, plug_name: str) -> int | None:
        for i in range(self.display.get_n_monitors()):
            if self.display.get_default_screen().get_monitor_plug_name(i) == plug_name:
                return i
        return None

    def get_gdk_monitor_id(self, hyprland_id: int) -> int | None:
        monitors = self.get_all_monitors()
        if hyprland_id in monitors:
            return self.get_gdk_monitor_id_from_name(monitors[hyprland_id])
        return None

    def get_current_gdk_monitor_id(self) -> int:
        active_workspace = json.loads(self.send_command("j/activeworkspace").reply)
        id = self.get_gdk_monitor_id_from_name(active_workspace["monitor"])
        return id if id else 0

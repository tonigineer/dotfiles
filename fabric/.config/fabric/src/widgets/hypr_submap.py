from fabric.hyprland.widgets import get_hyprland_connection
from fabric.widgets.box import Box
from fabric.widgets.image import Image
from fabric.widgets.label import Label


class HyprSubmap(Box):
    """A widget to display the current sub map."""

    def __init__(self, **kwargs):
        super().__init__(name="submap", orientation='horizontal', spacing=5, **kwargs)
        self.submap_label = Label(label="default")
        self.children = [
            Image(icon_size=18, icon_name="submap-icon"),
            self.submap_label
        ]

        self.connection = get_hyprland_connection()
        self.connection.connect("event::submap", self.get_submap)

        self.on_ready(None) if self.connection.ready else \
            self.connection.connect("event::ready", self.on_ready)

    def on_ready(self, _):
        return self.get_submap()

    def get_submap(self, *_):
        submap = str(self.connection.send_command("submap").reply.decode()).strip("\n")

        self.submap_label.set_label(f"{submap}")
        self.set_tooltip_text(
            f"Current submap: {submap}\n\nReset with <ESC>\nChange with <MOD>+<SPACE>",
        )

        self.set_visible(submap != "default")

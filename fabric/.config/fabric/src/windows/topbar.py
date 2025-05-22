from fabric.widgets.box import Box
from fabric.widgets.centerbox import CenterBox
from fabric.widgets.wayland import WaylandWindow as Window
from loguru import logger

from src.utils.config import Config
from src.widgets import (
    ArchLogo,
    Clock,
    HyprClient,
    HyprSubmap,
    HyprWorkspaces,
    PowerButton,
    Separator,
)

cfg = Config.get()["windows"]["topbar"]

widget_list = {
    "left": ["ArchLogo", "HyprClient", "HyprSubmap"],
    "center": ["HyprWorkspaces"],
    "right": ["Clock", "PowerButton"],
}

class TopBar(Window):
    """Bar for the top of the screen."""

    def __init__(self, **kwargs):
        layout = self.make_layout(kwargs['monitor'])

        self.box = CenterBox(
            name="container",
            start_children=Box(
                name="left",
                spacing=cfg["spacing"],
                orientation="h",
                children=layout["left"],
            ),
            center_children=Box(
                name="center",
                spacing=cfg["spacing"],
                orientation="h",
                children=layout["middle"],
            ),
            end_children=Box(
                name="right",
                spacing=cfg["spacing"],
                orientation="h",
                children=layout["right"],
            ),
        )

        super().__init__(
            name="top-bar",
            layer="top",
            anchor= "left top right",
            pass_through=False,
            exclusivity="auto",
            visible=True,
            all_visible=False,
            child=self.box,
            **kwargs,
        )

    def make_layout(self, monitor) -> dict:
        layout = {
            "left": [
                Separator(style=f"min-width: {cfg['separator-width']}"),
                ArchLogo(),
                HyprSubmap(),
                HyprClient()
            ],
            "middle": [
                HyprWorkspaces(monitor=monitor)
            ],
            "right": [
                Clock(),
                PowerButton(),
                Separator(style=f"min-width: {cfg['separator-width']}"),
            ]
        }

        return layout

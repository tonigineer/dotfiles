from fabric.widgets.box import Box
from fabric.widgets.centerbox import CenterBox
from fabric.widgets.datetime import DateTime
from fabric.widgets.wayland import WaylandWindow as Window

from src.utils.config import Config
from src.widgets.arch_logo import ArchLogo
from src.widgets.clock import Clock

cfg = Config.get()["windows"]["topbar"]

widget_list = {
    "left": ["ArchLogo", "Client", "Submap"],
    "center": ["Workspace"],
    "right": ["Clock", "Powerbutton"],
}

class TopBar(Window):
    """Bar for the top of the screen."""

    def __init__(self, **kwargs):
        layout = self.make_layout()

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

    def make_layout(self) -> dict:
        layout = {
            "left": [ Box(style="min-width: 0.5rem;"), ArchLogo()
            #     Box(),
            #     logo
            ],
          "middle": [DateTime(formatters="%H:%M")],
            "right": [Clock(), Box(style="min-width: 0.5rem;")],
        }
        return layout

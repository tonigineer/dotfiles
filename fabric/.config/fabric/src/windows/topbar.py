from fabric.widgets.box import Box
from fabric.widgets.centerbox import CenterBox
from fabric.widgets.wayland import WaylandWindow as Window

from src.utils.config import Config
from src.widgets import (
    ArchLogo,
    Clock,
    HyprClient,
    HyprSubmap,
    HyprWorkspaces,
    PowerMenuButton,
    Separator,
    SystemTray,
)
from src.widgets.hypr_picker import HyprPicker

Config.Windows.Topbar.spacing

# TODO implement dynamic building
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
                spacing=Config.Windows.Topbar.spacing,
                orientation="h",
                children=layout["left"],
            ),
            center_children=Box(
                name="center",
                spacing=Config.Windows.Topbar.spacing,
                orientation="h",
                children=layout["middle"],
            ),
            end_children=Box(
                name="right",
                spacing=Config.Windows.Topbar.spacing,
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
                Separator(style=f"min-width: {Config.Windows.Topbar.separator_width}"),
                ArchLogo(),
                HyprSubmap(),
                HyprClient()
            ],
            "middle": [
                HyprWorkspaces(monitor=monitor),
                HyprPicker()
            ],
            "right": [
                *(
                    [SystemTray()]
                    if monitor == Config.Widgets.SystemTray.monitor_id
                    else []
                ),
                Clock(),
                PowerMenuButton(),
                Separator(style=f"min-width: {Config.Windows.Topbar.separator_width}"),
            ]
        }

        return layout

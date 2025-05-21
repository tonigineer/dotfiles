from typing import Dict

from fabric.widgets.box import Box
from fabric.widgets.centerbox import CenterBox
from fabric.widgets.datetime import DateTime
from fabric.widgets.wayland import WaylandWindow as Window

from fabric.widgets.image import Image
from fabric.widgets.label import Label
from fabric.widgets.svg import Svg
from fabric.widgets.button import Button
from fabric.utils import (
    DesktopApp,
    bulk_connect,
    exec_shell_command,
    exec_shell_command_async,
    get_desktop_applications,
    get_relative_path,
    idle_add,
    invoke_repeater,
    monitor_file,
    remove_handler,
    set_stylesheet_from_file,
)




class TopBar(Window):
    def __init__(self, **kwargs):
        layout = self.make_layout()

        anchor = "left top right"

        self.box = CenterBox(
            name="panel-inner",
            start_children=Box(
                spacing=4,
                orientation="h",
                children=layout["left"],
            ),
            center_children=Box(
                spacing=4,
                orientation="h",
                children=layout["middle"],
            ),
            end_children=Box(
                spacing=4,
                orientation="h",
                children=layout["right"],
            ),
        )

        super().__init__(
            name="panel",
            layer="top",
            anchor=anchor,
            pass_through=False,
            exclusivity="auto",
            visible=True,
            all_visible=False,
            child=self.box,
            **kwargs,
        )

    def make_layout(self) -> Dict:
        # logo = Button(
        #     name="logo",
        #     child=Svg(
        #         size=20,
        #         svg_file="arch-symbolic.svg",
        #         style="fill: #FFFFFF;",
        #     )
        # )
        layout = {
            "left": [DateTime()
            #     Box(),
            #     logo
            ],
          "middle": [DateTime()],
            "right": [DateTime()],
        }
        return layout

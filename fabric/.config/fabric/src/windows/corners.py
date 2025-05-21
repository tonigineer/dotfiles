from fabric.widgets.box import Box
from fabric.widgets.shapes import Corner
from src.utils.config import Config

from fabric.widgets.svg import compile_css
from fabric.widgets.wayland import WaylandWindow as Window
class SideCorner(Box):
    """A container for a corner shape."""

    def __init__(self, corner, size):
        super().__init__(
            name="corner-container",
            children=Corner(
                style=f"background-color: black; min-width: {size}px; min-height: {size}px",
                name="corner",
                orientation=corner,
                size=size,
            ),
        )


class ScreenCorners(Window):
    """A window that displays all four corners."""

    def __init__(self, size=Config.get()["windows"]["corners"]["size"]):
        super().__init__(
            name="corners",
            layer="top",
            anchor="top bottom left right",
            exclusivity="normal",
            pass_through=True,
            visible=False,
            all_visible=False,
        )

        self.all_corners = Box(
            name="all-corners",
            orientation="v",
            h_expand=True,
            v_expand=True,
            h_align="fill",
            v_align="fill",
            children=[
                Box(
                    name="top-corners",
                    orientation="h",
                    h_align="fill",
                    children=[
                        SideCorner("top-left", size),
                        Box(h_expand=True),
                        SideCorner("top-right", size),
                    ],
                ),
                Box(v_expand=True),
                Box(
                    name="bottom-corners",
                    orientation="h",
                    h_align="fill",
                    children=[
                        SideCorner("bottom-left", size),
                        Box(h_expand=True),
                        SideCorner("bottom-right", size),
                    ],
                ),
            ],
        )

        self.add(self.all_corners)

        self.show_all()

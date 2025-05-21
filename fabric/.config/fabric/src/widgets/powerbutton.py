from fabric import Fabricator
from fabric.utils import exec_shell_command_async, get_relative_path
from fabric.widgets.box import Box
from fabric.widgets.label import Label
from fabric.widgets.image import Image

# import utils.functions as helpers
from fabric.widgets.button import Button
# from utils import BarConfig, ExecutableNotFoundError
from gi.repository import Gtk
#
# icon_theme = Gtk.IconTheme.get_default()

# print(icon_theme)
# breakpoint()
#
from src.utils.config import Config
#
cfg = Config.get()["windows"]["topbar"]

class ArchLogo(Button):
    """A widget to display the Cava audio visualizer."""

    def __init__(self, **kwargs):
        super().__init__(
            name="arch-logo",
            # child=Label("ArchLogo"),
            image=Image(icon_size=, icon_name="arch-logo"),
            tooltip_text="dfasfdfa",
            on_clicked=lambda *_: exec_shell_command_async("kitty"),
            **kwargs
        )


        # cava_command = "cava"

        # if not helpers.executable_exists(cava_command):
        #     raise ExecutableNotFoundError(cava_command)

        # if not helpers.is_valid_gjs_color(self.config["color"]):
        #     raise ValueError("Invalid color supplied for cava widget")

        # command = f"kitty --title systemupdate sh -c '{cava_command}'"

        # cava_label = Label(
        #     v_align="center",
        #     h_align="center",
        #     style=f"color: {self.config['color']};",
        # )

        # script_path = get_relative_path("../assets/scripts/cava.sh")

        # self.box.children = Box(spacing=1, children=[cava_label]).build(
        #     lambda box, _: Fabricator(
        #         poll_from=f"bash -c '{script_path} {self.config['bars']}'",
        #         stream=True,
        #         on_changed=lambda f, line: cava_label.set_label(line),
        #     )
        # )

        # self.connect(
        #     "clicked", lambda _: exec_shell_command_async(command, lambda *_: None)
        # )

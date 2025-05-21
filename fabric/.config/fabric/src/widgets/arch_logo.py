from fabric.utils import exec_shell_command_async
from fabric.widgets.button import Button
from fabric.widgets.image import Image

from src.utils.config import Config

cfg = Config.get()["windows"]["topbar"]

class ArchLogo(Button):
    """A widget to display Arch Logo button."""

    def __init__(self, **kwargs):
        super().__init__(
            name="arch-logo",
            # child=Label("ArchLogo"),
            image=Image(icon_size=cfg["icon-size"], icon_name="arch-logo"),
            tooltip_text="dfasfdfa",
            on_clicked=lambda *_: exec_shell_command_async("kitty"),
            **kwargs
        )

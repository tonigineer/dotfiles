from fabric.utils import exec_shell_command_async
from fabric.widgets.button import Button
from fabric.widgets.image import Image
from gi.repository import GLib

from src.utils.common import ttl_lru_cache
from src.utils.config import Config
from src.utils.icons import text_icons

cfg = Config.get()["windows"]["topbar"]


@ttl_lru_cache(600, 10)
def get_distro_icon():
    distro_id = GLib.get_os_info("ID")
    return text_icons["distro"].get(distro_id, "")


class ArchLogo(Button):
    """A widget to display Arch Logo button."""

    def __init__(self, **kwargs):
        super().__init__(
            name="arch-logo",
            # child=Label("ArchLogo"),
            image=Image(icon_size=cfg["icon-size"], icon_name="arch-logo"),
            tooltip_text=f"{get_distro_icon()}dfasfdfa",
            on_clicked=lambda *_: exec_shell_command_async("kitty"),
            **kwargs
        )

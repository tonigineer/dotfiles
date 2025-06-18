from fabric.utils import exec_shell_command_async
from fabric.utils.helpers import exec_shell_command
from fabric.widgets.button import Button
from fabric.widgets.image import Image
from gi.repository import Gdk
from loguru import logger

from src.utils.common import executable_exists, send_notification
from src.utils.config import Config
from src.utils.widgets import setup_cursor_hover


class HyprPicker(Button):
    """A widget to use hyprpicker."""

    cmd = "hyprpicker -a -n"

    def __init__(self, **kwargs):
        if not executable_exists("hyprpicker"):
            logger.error("Hyprpicker was not found on the system. Run `yay -S hyprpicker`.")

        super().__init__(
            name="arch-logo",
            image=Image(
                icon_size=Config.Windows.Topbar.icon_size,
                icon_name="color-picker"
            ),
            tooltip_text="""Hyprpicker  󰸵 HEX | 󰸷 RGB""",
            **kwargs
        )

        setup_cursor_hover(self)
        self.connect("button-press-event", self.on_button_press)


    def on_button_press(self, button, event):
            if event.button == 1:
                exec_shell_command_async(
                    f"{self.cmd} -f hex",
                    lambda stdout, *_: self.notify(stdout)
                )
            elif event.button == 3:
                exec_shell_command_async(
                    f"{self.cmd} -f rgb",
                    lambda stdout, *_: self.notify(stdout)
                )

    def notify(self, stdout: str) -> None:
        if stdout.startswith("#"):
            pass
        elif len(stdout.split()) == 3:
            stdout = f"rgb({stdout})"
        else:
            logger.warning(f"Hyprpicker output `{stdout}` could not be processed. Not supposed to happen.")
            return

        exec_shell_command(f'magick -size 64x64 xc:"{stdout}" /tmp/color.png')

        send_notification(
            title="Hyprpicker",
            body=f"{stdout} copied to clipboard.",
            urgent=False,
            icon="/tmp/color.png",
            timeout=1_500
        )

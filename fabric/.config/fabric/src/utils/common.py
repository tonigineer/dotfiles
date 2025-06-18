import shutil
import time
import uuid
from functools import lru_cache

from fabric.utils import cooldown, exec_shell_command_async
from gi.repository import Gdk, Gio, GLib, Gtk
from loguru import logger

from src.utils.thread import run_in_thread


def ttl_lru_cache(seconds_to_live: int, maxsize: int = 128):
    def wrapper(func):
        @lru_cache(maxsize)
        def inner(__ttl, *args, **kwargs):
            return func(*args, **kwargs)

        return lambda *args, **kwargs: inner(
            time.time() // seconds_to_live, *args, **kwargs
        )
    return wrapper


@ttl_lru_cache(600, 10)
def executable_exists(executable_name: str) -> bool:
    """Simply use `which` to check if executable exists."""
    executable_path = shutil.which(executable_name)
    return bool(executable_path)

# @cooldown(1)
# def send_notification(
#     title: str,
#     body: str,
#     timeout: int = 1000,
#     urgent: bool = False,
#     icon: Optional[str] = None,
# ):
#     notification = Gio.Notification.new(title)
#     notification.set_body(body)
#     notification.set_urgent(True)
#     # notification.set_property('timeout', 1000)

#     if icon:
#         notification.set_icon(Gio.ThemedIcon.new(icon))

#     application = Gio.Application.get_default()

#     application.send_notification(None, notification)
#     # return True




def send_notification(
    title: str,
    body: str,
    timeout: int = 1_000,
    urgent: bool = False,
    icon: str | None = None,
):
    """
    Show a desktop notification via the active Gio.Application
    and auto-withdraw it after *timeout* ms.

    Parameters
    ----------
    title : str
        Summary text shown in bold.
    body : str
        Main message body.
    timeout : int, default 1000
        Milliseconds to keep the bubble on screen.
    urgent : bool, default False
        Raise priority to “urgent”.
    icon : str | None
        Name of a themed icon to display.

    Example
    -------
    >>> send_notification(
    ...     title="Build finished",
    ...     body="All tests passed",
    ...     timeout=5000,
    ...     icon="dialog-information-symbolic",
    ... )
    """
    app = Gio.Application.get_default()
    if app is None:
        raise RuntimeError("No running Gio.Application")

    notif = Gio.Notification.new(title)
    notif.set_body(body)

    if urgent:
        notif.set_priority(Gio.NotificationPriority.URGENT)
    if icon:
        notif.set_icon(Gio.ThemedIcon.new(icon))

    nid = str(uuid.uuid4())
    app.send_notification(nid, notif)

    GLib.timeout_add(
        timeout,
        lambda: (app.withdraw_notification(nid), False)[1],
    )

@cooldown(1)
@run_in_thread
def play_sound(file: str):
    exec_shell_command_async(f"pw-play {file}", lambda *_: None)
    return True

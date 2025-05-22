from typing import Literal

from fabric.utils import bulk_connect
from gi.repository import Gdk, GLib


# Function to setup cursor hover
def setup_cursor_hover(
    widget, cursor_name: Literal["pointer", "crosshair", "grab"] = "pointer"
):
    display = Gdk.Display.get_default()

    def on_enter_notify_event(widget, _):
        cursor = Gdk.Cursor.new_from_name(display, cursor_name)
        widget.get_window().set_cursor(cursor)

    def on_leave_notify_event(widget, _):
        cursor = Gdk.Cursor.new_from_name(display, "default")
        widget.get_window().set_cursor(cursor)

    bulk_connect(
        widget,
        {
            "enter-notify-event": on_enter_notify_event,
            "leave-notify-event": on_leave_notify_event,
        },
    )

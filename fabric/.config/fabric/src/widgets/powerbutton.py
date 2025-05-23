from select import EPOLLEXCLUSIVE
from typing import Literal

from fabric.utils import bulk_connect
from fabric.utils.helpers import exec_shell_command_async
from fabric.widgets.box import Box
from fabric.widgets.button import Button
from fabric.widgets.datetime import DateTime
from fabric.widgets.eventbox import EventBox
from fabric.widgets.label import Label
from fabric.widgets.revealer import Revealer
from fabric.widgets.stack import Stack
from fabric.widgets.wayland import WaylandWindow as Window
from fabric.widgets.widget import Widget
from gi.repository import Gdk, GdkPixbuf, GLib, Gtk
from loguru import logger

from src.utils.icons import nerd_font_icons
from src.utils.monitors import HyprlandWithMonitors
from src.utils.types import Anchor, KeyboardMode, Layer, TransitionType


class Padding(Box):
    """A widget to add some padding around a revealer.

    If there are not Widgets around the revealer, it is not shown.
    Also, the min-width and min-height are necessary here.

    TODO: should be working without needing this.
    """

    def __init__(self, name: str | None = None, style: str = "", **kwargs):
        super().__init__(
            style="background-color: transparent;min-height: 1px;min-width: 1px;",
            h_expand=False,
            v_expand=False,
            **kwargs,
        )
        self.set_can_focus(False)


class RevealPopUpWindow(Window):
    """A pop up window that uses a revealer to be shown."""

    _timeout_id: int | None = None

    def __init__(self,
        name: str,
        content: Widget,
        anchor: Anchor = "top-right",
        layer: Layer = "top",
        keyboard_mode: KeyboardMode = "on-demand",
        transition_type: TransitionType= "slide-down",
        transition_duration: int = 400,
        timeout_duration: int = 2000,
        **kwargs
    ):
        self.timeout_duration = timeout_duration

        self.revealer = Revealer(
            child_revealed=False,
            transition_type=transition_type,
            transition_duration=transition_duration,
            child=content,
            notify_child_revealed=lambda revealer, _: [
                self.hide(),
            ] if not revealer.fully_revealed else None,
            notify_reveal_child=lambda revealer, _: [
                self.show(),
            ] if revealer.child_revealed else None,
        )

        # NOTE: to avoid an empty bock with an unrevealed revealer,
        #   some padding widgets are put around it. There must be
        #   a better way -> TODO.
        self.child = Box(orientation="h",
            children=[
                Padding(**kwargs),
                Box(orientation="v",
                    children=[
                        Padding(*kwargs),
                        self.revealer,
                        Padding(**kwargs)
                    ]
                ),
                Padding(**kwargs)
            ]
        )

        super().__init__(
            name=name,
            layer=layer,
            anchor=anchor,
            exclusivity="none",
            visible=True,
            all_visible=True,
            keyboard_mode=keyboard_mode,
            child=self.child,
            on_key_release_event=self.on_key_release,
            **kwargs,
        )

        if self.timeout_duration > 0:
            bulk_connect(
                self,
                {
                    # "button-press-event": self.revealer.unreveal,
                    # "enter-notify-event": self.on_focus,
                    # "leave-notify-event": self.on_focus_out,
                    "focus-in-event": self.stop_timeout,
                    "focus-out-event": self.start_timeout,
                }
            )

    def start_timeout(self, *_):
        self.stop_timeout()
        self._timeout_id = GLib.timeout_add(self.timeout_duration, self.revealer.unreveal)

    def stop_timeout(self, *_):
        if self._timeout_id is not None:
            GLib.source_remove(self._timeout_id)
            self._timeout_id = None

    def on_key_release(self, _, event_key):
        if event_key.keyval == Gdk.KEY_Escape:
            if self.revealer.child_revealed:
                self.revealer.unreveal()
            else:
                self.revealer.reveal()

import psutil

from src.utils.system_stats import util_fabricator


class PowerButton(EventBox):
    """A widget to display time and datetime."""

    _pop_up_menu = None

    def __init__(self, **kwargs):
        super().__init__(
            name="power-menu",
            orientation="h",
            spacing=4,
            v_align="center",
            h_align="center",
            visible=True,
            **kwargs,
        )

        self.set_can_focus(True)

        self.content = Label("New Revealer")

        self.pm = Button("   X    ")
        self.pm.connect("clicked", self.toggle_popup)
        self.children = self.pm





        # self.set_can_focus(True)
        # self.pm.set_can_focus(True)

        # bulk_connect(
        #     self,
        #     {
        #         "button-press-event": self.test,
        #         "enter-notify-event": self.test,
        #         "leave-notify-event": self.test,
        #     },
        # )



        # self.pm.connect("focus-out-event", self.test)
        # self.pm.connect("focus-in-event", self.test)
    def test(self, *_):
        logger.info("dasrfsdfsad")
    def get_pop_up_menu(self):
        if PowerButton._pop_up_menu is None:
            PowerButton._pop_up_menu = RevealPopUpWindow(
                name="power-menu-pop-up",
                content=self.content
            )
        return PowerButton._pop_up_menu



    def toggle_popup(self, *_):
        if self.get_pop_up_menu().revealer.child_revealed:
            self.get_pop_up_menu().revealer.unreveal()
        else:
            self.get_pop_up_menu().revealer.reveal()

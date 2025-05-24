import gi
from fabric.widgets.box import Box
from fabric.widgets.image import Image
from gi.repository import Gdk, Gray
from loguru import logger

from src.utils.config import Config
from src.widgets.misc import HoverButton

# Dependency
#   yay -S gray-git
gi.require_version("Gray", "0.1")


class SystemTray(Box):
    """A widget to display the system tray items."""

    # TODO: Make available on all monitors. Since the item added call
    #   comes only once, there is a global item storage needed. But
    #   one item can be used on two SystemTray instances, if I checked
    #   out correctly.
    def __init__(self, **kwargs):
        super().__init__(name="system_tray", **kwargs)

        self.item_box = Box(
            name="system-tray-box",
            spacing=Config.Windows.Topbar.spacing,
            orientation="horizontal",
        )

        self.children= [self.item_box]

        self.watcher = Gray.Watcher()
        self.watcher.connect("item-added", self.on_item_added)

        for item_id in self.watcher.get_items():
            self.on_item_added(self.watcher, item_id)

    def on_item_added(self, _, identifier: str):
        "Create button for system tray item."

        item = self.watcher.get_item_for_identifier(identifier)
        if not item:
            return

        title = item.get_property("title") or ""

        button = HoverButton(
            style_classes="flat", tooltip_text=title, margin_start=2, margin_end=2
        )
        button.connect(
            "button-press-event",
            lambda button, event: self.on_button_click(
                button, item, event
            ),
        )

        name = item.get_property("title").lower()
        if name not in Config.Widgets.SystemTray.svg_icon_map:
            logger.warning(f"No icon for item: `{name}` defined")

        button.set_image(Image(
            icon_name=Config.Widgets.SystemTray.svg_icon_map[name],
            icon_size=Config.Windows.Topbar.icon_size,
        ))

        button.connect(
            "button-press-event",
            lambda button, event: self.on_button_click(button, item, event),
        )

        item.connect("removed", lambda *args: button.destroy())
        item.connect(
            "icon-changed",
            lambda icon_item: self.do_update_item_button(icon_item, button)
        )

        button.show_all()
        self.item_box.pack_start(button, False, False, 0)

    def do_update_item_button(self, item: Gray.Item, button: HoverButton) -> None:
        logger.error("implement own svg's here!!!")
        button.set_image(Image(icon_name="arch-logo"))

    def on_button_click(self, button: HoverButton, item: Gray.Item, event) -> None:
        if event.button in (1, 3):
            menu = item.get_property("menu")
            if menu:
                menu.popup_at_widget(
                    button,
                    Gdk.Gravity.SOUTH,
                    Gdk.Gravity.NORTH,
                    event,
                )
            else:
                item.context_menu(event.x, event.y)

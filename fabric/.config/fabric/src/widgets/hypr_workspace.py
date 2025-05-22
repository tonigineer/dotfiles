import json

from fabric.hyprland.widgets import WorkspaceButton as WsButton
from fabric.hyprland.widgets import Workspaces, get_hyprland_connection
from fabric.widgets.box import Box

from src.utils.config import Config
from src.utils.widgets import setup_cursor_hover

cfg = Config.get()["widgets"]["workspaces"]


class WorkspaceButton(WsButton):
    """A button to represent a workspace."""

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        setup_cursor_hover(self)

class HyprWorkspaces(Box):
    """A widget to display the current workspaces."""

    ws_numbers = cfg["numberings"][cfg["numbering"]]

    def __init__(self, monitor, **kwargs):
        super().__init__(name="workspaces", **kwargs)
        self.monitor = monitor
        self.connection = get_hyprland_connection()

        @staticmethod
        def create_workspace_label(ws_id: int) -> str:
            # TODO: add icons of windows
            return self.ws_numbers[ws_id - 1]

        @staticmethod
        def set_up_buttons(button: WsButton) -> WsButton:
            """Set button state including filter for monitors."""
            workspaces = json.loads(str(
                self.connection.send_command("j/workspaces").reply.decode()
            ))
            monitor_id = next(
                ws["monitorID"] for ws in workspaces if ws["id"] == button.id
            )
            button.set_visible(monitor_id == self.monitor)

            def update_empty_state(*_):
                if button.get_empty():
                    button.add_style_class("unoccupied")
                else:
                    button.remove_style_class("unoccupied")

            button.connect("notify::empty", update_empty_state)
            update_empty_state()

            return button

        self.children = Workspaces(
            name="workspaces",
            spacing=4,
            buttons_factory=lambda ws_id: set_up_buttons(
                WorkspaceButton(
                    id=ws_id,
                    label=create_workspace_label(ws_id),
                )
            ),
            invert_scroll=True,
            empty_scroll=False  # must be false, because of not showing unoccupied
        )

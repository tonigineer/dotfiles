import re

from fabric.hyprland.widgets import ActiveWindow
from fabric.utils import FormattedString
from fabric.widgets.box import Box

from src.utils.windows import WINDOW_REGEX_MAP


class HyprClient(Box):
    """A widget to display the current clients window title."""

    def __init__(self, **kwargs):
        super().__init__(name="client", orientation='horizontal', spacing=5, **kwargs)
        self.active_window = ActiveWindow(
            formatter=FormattedString(
                "{ get_title(win_title, win_class) }",
                get_title=self.get_title,
            ),
        )
        self.children = [self.active_window]

    def get_title(self, win_title, win_class):
        # Give prio to more specific window titles (e.g., whatsapp in librewolf)
        prio_window_title_list = list(reversed(WINDOW_REGEX_MAP))
        matched_window = next(
            (wt for wt in prio_window_title_list
             if re.search(wt[0], win_title.lower())),
            None
        )

        if not matched_window:
            matched_window = next(
                (wt for wt in prio_window_title_list
                 if re.search(wt[0], win_class.lower())),
                None
            )

        if not matched_window:
            return f"MISSING | class: {win_class.lower()} title: {win_class.lower()}"

        return (
            f"{matched_window[1]} {matched_window[2]}"
            if False
            else f"{matched_window[2]}"
        )

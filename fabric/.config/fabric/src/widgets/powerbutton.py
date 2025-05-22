from fabric.widgets.box import Box
from fabric.widgets.datetime import DateTime

formattings = ["%H:%M", "%d.%m.%Y  %H:%M"]


class PowerButton(Box):
    """A widget to display time and datetime."""

    format_idx = 0

    def __init__(self, **kwargs):
        super().__init__(name="clock", **kwargs)

        self.datetime = DateTime(formatters=formattings[self.format_idx])
        self.datetime.connect("clicked", self.change_formatting)
        self.children = [self.datetime]

    def change_formatting(self, *_):
        self.format_idx = (self.format_idx + 1) % len(formattings)
        self.datetime.formatters=formattings[self.format_idx]

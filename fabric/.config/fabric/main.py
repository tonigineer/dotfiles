from typing import Literal

import setproctitle
from fabric import Application
from fabric.widgets.shapes.star import Widget

from src.utils.config import Config
from src.utils.monitors import HyprlandWithMonitors
from src.utils.styles import Styles
from src.windows import DesktopInfo, ScreenCorners, TopBar


def main():
    windows = []
    match Config.General.show_on:
         case "all":
            monitors: list[int] = [
                int(k) for (k, _) in HyprlandWithMonitors().get_all_monitors().items()
            ]
         case "primary":
            monitors:list[int] = [HyprlandWithMonitors().get_current_gdk_monitor_id()]

    if Config.Windows.Topbar.enabled:
        for monitor in monitors:
            windows.extend(TopBar(monitor=monitor))

    if Config.Windows.Corners.enabled:
        for monitor in monitors:
            windows.extend(ScreenCorners(monitor=monitor))

    if Config.Windows.DesktopInfo.enabled:
        for monitor in monitors:
            windows.extend(DesktopInfo(monitor=monitor, date_format="%A, %d %B %Y"))

    app = Application(Config.application_name, windows=windows)

    Styles.init(app)
    Styles.monitor_files()

    setproctitle.setproctitle(Config.application_name)
    app.run()

if __name__ == "__main__":
    dock = None
    hud = None  # on screen display for sound, brightness
    desktop_info = None  # info for empty workspaces

    top_bar = None
    bottom_bar = None
    osd = None  # All menus whne clicking the bars

    launcher = None

    main()

import setproctitle
from fabric import Application

from src.utils.config import APPLICATION_NAME, Config
from src.utils.monitors import HyprlandWithMonitors
from src.utils.styles import Styles
from src.windows import DesktopClock, ScreenCorners, TopBar


def main():
    windows = []

    # TODO: implement primary display only
    if Config.get()["windows"]["topbar"]["enabled"]:
        for monitor in HyprlandWithMonitors().get_all_monitors():
            windows.extend(TopBar(monitor=monitor))

    if Config.get()["windows"]["corners"]["enabled"]:
        for monitor in HyprlandWithMonitors().get_all_monitors():
            windows.extend(ScreenCorners(monitor=monitor))

    if Config.get()["windows"]["corners"]["enabled"]:
        for monitor in HyprlandWithMonitors().get_all_monitors():
            windows.extend(DesktopClock(monitor=monitor, date_format="%A, %d %B %Y"))

    app = Application(APPLICATION_NAME, windows=windows)

    Styles.init(app)
    Styles.monitor_files()

    setproctitle.setproctitle(APPLICATION_NAME)
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

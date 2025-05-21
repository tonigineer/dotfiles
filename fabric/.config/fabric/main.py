import setproctitle
from fabric import Application

from src.utils.config import APPLICATION_NAME, Config
from src.utils.monitors import HyprlandWithMonitors
from src.utils.styles import Styles
from src.windows.corners import ScreenCorners
from src.windows.topbar import TopBar


def main():
    windows = []

    # TODO: implement primary display only
    if Config.get()["windows"]["topbar"]["enabled"]:
        for monitor_id in HyprlandWithMonitors().get_all_monitors():
            windows.append(TopBar(monitor=monitor_id))

    if Config.get()["windows"]["corners"]["enabled"]:
        windows.append(ScreenCorners())

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

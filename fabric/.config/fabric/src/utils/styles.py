from fabric import Application
from fabric.utils import exec_shell_command, monitor_file
from loguru import logger

from src.utils.config import Config

from .colors import Colors


class Styles:
    """Styles class for managing application styles."""

    _app = None

    @classmethod
    def init(cls, app: Application):
        cls._app = app
        cls._apply()

    @classmethod
    def apply(cls, *_):
        cls._apply()

    @classmethod
    def monitor_files(cls):
        cls.style_monitor = monitor_file(
            str(Config.Paths.config_dir / Config.Styles.monitor_dir)
        )
        cls.style_monitor.connect("changed", Styles.apply)

    @classmethod
    def _apply(cls):
        if cls._app is None:
            logger.error(f"{Colors.WARNING}[Styles] Application not initialized!")
            return

        logger.info(f"{Colors.INFO}[Styles] Compiling CSS")
        stdout = exec_shell_command(
            f"sass {Config.Paths.config_dir / Config.Styles.compile_source} \
            {Config.Paths.config_dir / Config.Styles.compile_target} --no-source-map"
        )

        if stdout == "":
            logger.info(f"{Colors.INFO}[Styles] CSS applied")
            cls._app.set_stylesheet_from_file(str(
                Config.Paths.config_dir / Config.Styles.compile_target
            ))
        else:
            cls._app.set_stylesheet_from_string(
                """* {
                    all: unset;
                }""".strip()
            )
            logger.error(f"{Colors.WARNING}[Styles] Failed to compile sass!")

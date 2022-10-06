# -*- coding: utf-8 -*-

import coloredlogs

DEFAULT_LEVEL_STYLES = {
    "spam": {"color": "green", "faint": True},
    "debug": {"color": "green"},
    "verbose": {"color": "blue"},
    "info": {},
    "notice": {"color": "magenta"},
    "warning": {"color": "yellow"},
    "success": {"color": "green", "bold": True},
    "error": {"color": "red"},
    "critical": {"color": "red", "bold": True},
}

DEFAULT_FIELD_STYLES = {
    "asctime": {"color": "green"},
    "hostname": {"color": "magenta"},
    "process": {"color": "magenta"},
    "thread": {"color": "cyan"},
    "levelname": {"bold": True},
    "name": {"color": "blue"},
    "username": {"color": "yellow"},
}


class ColoredFormatter(coloredlogs.ColoredFormatter):
    def __init__(self, fmt=None, datefmt=None, style="%"):
        """
        Match `coloredlogs.ColoredFormatter` arguments with `logging.Formatter`
        """

        super().__init__(
            fmt=fmt,
            datefmt=datefmt,
            style=style,
            level_styles=DEFAULT_LEVEL_STYLES,
            field_styles=DEFAULT_FIELD_STYLES,
        )

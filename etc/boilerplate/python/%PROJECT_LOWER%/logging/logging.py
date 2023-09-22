# -*- coding: utf-8 -*-

from logging import (
    CRITICAL,
    DEBUG,
    ERROR,
    FATAL,
    INFO,
    NOTSET,
    WARN,
    WARNING,
    Formatter,
    StreamHandler,
)
from logging import config as logging_config
from logging import getLogger
from logging.handlers import TimedRotatingFileHandler
from sys import stdout
from typing import Final, Literal, Optional, Union

SEVERITY_NAME_CRITICAL = "critical"
SEVERITY_NAME_FATAL = "fatal"
SEVERITY_NAME_ERROR = "error"
SEVERITY_NAME_WARNING = "warning"
SEVERITY_NAME_WARN = "warn"
SEVERITY_NAME_INFO = "info"
SEVERITY_NAME_DEBUG = "debug"
SEVERITY_NAME_NOTSET = "notset"
SEVERITY_NAME_OFF = "off"

SEVERITIES = (
    SEVERITY_NAME_CRITICAL,
    SEVERITY_NAME_FATAL,
    SEVERITY_NAME_ERROR,
    SEVERITY_NAME_WARNING,
    SEVERITY_NAME_WARN,
    SEVERITY_NAME_INFO,
    SEVERITY_NAME_DEBUG,
    SEVERITY_NAME_NOTSET,
    SEVERITY_NAME_OFF,
)

LoggingStyleLiteral = Literal["%", "{", "$"]
TimedRotatingWhenLiteral = Literal[
    "S", "M", "H", "D", "W0", "W1", "W2", "W3", "W4", "W5", "W6", "midnight"
]  # W0=Monday

DEFAULT_SIMPLE_LOGGING_FORMAT: Final[str] = "{levelname[0]} [{name}] {message}"
DEFAULT_SIMPLE_LOGGING_STYLE: Final[LoggingStyleLiteral] = "{"

FMT_TIME: Final[str] = "%(asctime)s.%(msecs)03d"
FMT_THREAD: Final[str] = "%(process)d/%(thread)s"

DEFAULT_FORMAT = f"{FMT_TIME} {FMT_THREAD} %(name)s %(levelname)s %(message)s"
DEFAULT_DATEFMT: Final[str] = "%Y-%m-%d %H:%M:%S"
DEFAULT_STYLE: Final[LoggingStyleLiteral] = "%"

SIMPLE_FORMAT: Final[str] = "{levelname[0]} {asctime} {name} {message}"
SIMPLE_DATEFMT: Final[str] = "%Y%m%d %H%M%S"
SIMPLE_STYLE: Final[LoggingStyleLiteral] = "{"

DEFAULT_LOGGING_CONFIG = {
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        "default": {
            "format": DEFAULT_FORMAT,
            "datefmt": DEFAULT_DATEFMT,
            "style": DEFAULT_STYLE,
        },
        "simple": {
            "format": SIMPLE_FORMAT,
            "datefmt": SIMPLE_DATEFMT,
            "style": SIMPLE_STYLE,
        },
        "color": {
            "class": "%PROJECT_LOWER%.logging.colored_formatter.ColoredFormatter",
            "format": DEFAULT_FORMAT,
            "datefmt": DEFAULT_DATEFMT,
            "style": DEFAULT_STYLE,
        },
    },
    "handlers": {
        "console_default": {
            "class": "logging.StreamHandler",
            "level": "DEBUG",
            "formatter": "default",
            "stream": "ext://sys.stdout",
        },
        "console_simple": {
            "class": "logging.StreamHandler",
            "level": "DEBUG",
            "formatter": "simple",
            "stream": "ext://sys.stdout",
        },
        "console_color": {
            "class": "logging.StreamHandler",
            "level": "DEBUG",
            "formatter": "color",
            "stream": "ext://sys.stdout",
        },
        "file_default": {
            "class": "logging.FileHandler",
            "level": "DEBUG",
            "formatter": "default",
            "filename": "recc.log",
            "mode": "a",
            "encoding": "utf-8",
            "delay": False,
        },
    },
    "loggers": {
        "": {  # root logger
            "handlers": ["console_color"],
            "level": "DEBUG",
        },
    },
}

DEFAULT_LOGGER_NAME = "%PROJECT_LOWER%"

logger = getLogger(DEFAULT_LOGGER_NAME)


def convert_level_number(level: Optional[Union[str, int]] = None) -> int:
    if level is None:
        return DEBUG

    if isinstance(level, str):
        ll = level.lower()
        if ll == SEVERITY_NAME_CRITICAL:
            return CRITICAL
        elif ll == SEVERITY_NAME_FATAL:
            return FATAL
        elif ll == SEVERITY_NAME_ERROR:
            return ERROR
        elif ll == SEVERITY_NAME_WARNING:
            return WARNING
        elif ll == SEVERITY_NAME_WARN:
            return WARN
        elif ll == SEVERITY_NAME_INFO:
            return INFO
        elif ll == SEVERITY_NAME_DEBUG:
            return DEBUG
        elif ll == SEVERITY_NAME_NOTSET:
            return NOTSET
        elif ll == SEVERITY_NAME_OFF:
            return CRITICAL + 100
        else:
            try:
                return int(ll)
            except ValueError:
                raise ValueError(f"Unknown level: {level}")
    elif isinstance(level, int):
        return level
    else:
        raise TypeError(f"Unsupported level type: {type(level)}")


def convert_printable_level(level: Union[str, int]) -> str:
    if isinstance(level, str):
        return level
    if isinstance(level, int):
        if level > CRITICAL:
            return "OverCritical"
        if level == CRITICAL:
            return "Critical"
        if level > ERROR:
            return "OverError"
        if level == ERROR:
            return "Error"
        if level > WARNING:
            return "OverWarning"
        if level == WARNING:
            return "Warning"
        if level > INFO:
            return "OverInfo"
        if level == INFO:
            return "Info"
        if level > DEBUG:
            return "OverDebug"
        if level == DEBUG:
            return "Debug"
        if level > NOTSET:
            return "OverNotSet"
        if level == NOTSET:
            return "NotSet"
    return str(level)


def set_root_level(level: Union[str, int]) -> None:
    getLogger().setLevel(convert_level_number(level))


def set_default_logging_config() -> None:
    logging_config.dictConfig(DEFAULT_LOGGING_CONFIG)


def add_colored_formatter_logging_config(level=DEBUG) -> None:
    from %PROJECT_LOWER%.logging.colored_formatter import ColoredFormatter

    formatter = ColoredFormatter(
        fmt=DEFAULT_FORMAT,
        datefmt=DEFAULT_DATEFMT,
        style=DEFAULT_STYLE,
    )

    handler = StreamHandler(stdout)
    handler.setFormatter(formatter)
    handler.setLevel(level)

    getLogger().addHandler(handler)


def add_rotate_file_logging_config(
    prefix: str,
    when: Union[str, TimedRotatingWhenLiteral] = "D",
    level=DEBUG,
) -> None:
    formatter = Formatter(
        fmt=DEFAULT_FORMAT,
        datefmt=DEFAULT_DATEFMT,
        style=DEFAULT_STYLE,
    )

    handler = TimedRotatingFileHandler(prefix, when)
    handler.suffix = "%Y%m%d_%H%M%S.log"
    handler.setFormatter(formatter)
    handler.setLevel(level)

    getLogger().addHandler(handler)


def add_simple_logging_config(level=DEBUG) -> None:
    formatter = Formatter(
        fmt=DEFAULT_SIMPLE_LOGGING_FORMAT,
        style=DEFAULT_SIMPLE_LOGGING_STYLE,
    )

    handler = StreamHandler(stdout)
    handler.setFormatter(formatter)
    handler.setLevel(level)

    getLogger().addHandler(handler)

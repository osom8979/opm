# -*- coding: utf-8 -*-

from argparse import REMAINDER, ArgumentParser, Namespace, RawDescriptionHelpFormatter
from functools import lru_cache
from typing import Final, List, Optional

from %PROJECT_LOWER%.logging.logging import SEVERITIES, SEVERITY_NAME_INFO

CMD_CLIENT: Final[str] = "client"
CMD_MODULES: Final[str] = "modules"
CMD_SERVER: Final[str] = "server"

PROG: Final[str] = "%PROJECT_LOWER%"
DESCRIPTION: Final[str] = "%PROJECT_DESC%"
EPILOG: Final[str] = ""

DEFAULT_SEVERITY: Final[str] = SEVERITY_NAME_INFO

CMD1 = "cmd1"
CMD2 = "cmd2"
CMDS = (CMD1, CMD2)

CMD1_HELP: Final[str] = ""
CMD1_EPILOG: Final[str] = ""

CMD2_HELP: Final[str] = ""
CMD2_EPILOG: Final[str] = ""

DEFAULT_BIND: Final[str] = "0.0.0.0"
DEFAULT_PORT: Final[int] = 8080
DEFAULT_TIMEOUT: Final[float] = 1.0


@lru_cache
def version() -> str:
    # [IMPORTANT] Avoid 'circular import' issues
    from %PROJECT_LOWER% import __version__

    return __version__


def add_cmd1_parser(subparsers) -> None:
    # noinspection SpellCheckingInspection
    parser = subparsers.add_parser(
        name=CMD1,
        help=CMD1_HELP,
        formatter_class=RawDescriptionHelpFormatter,
        epilog=CMD1_EPILOG,
    )
    assert isinstance(parser, ArgumentParser)

    parser.add_argument(
        "--bind",
        "-b",
        default=DEFAULT_BIND,
        metavar="bind",
        help=f"Bind address (default: '{DEFAULT_BIND}')",
    )
    parser.add_argument(
        "--port",
        "-p",
        default=DEFAULT_PORT,
        metavar="port",
        help=f"Port number (default: '{DEFAULT_PORT}')",
    )
    parser.add_argument(
        "--timeout",
        "-t",
        default=DEFAULT_TIMEOUT,
        type=float,
        help=f"Request timeout in seconds (default: {DEFAULT_TIMEOUT})",
    )


def add_cmd2_parser(subparsers) -> None:
    # noinspection SpellCheckingInspection
    parser = subparsers.add_parser(
        name=CMD2,
        help=CMD2_HELP,
        formatter_class=RawDescriptionHelpFormatter,
        epilog=CMD2_EPILOG,
    )
    assert isinstance(parser, ArgumentParser)

    parser.add_argument(
        "--config",
        "-c",
        default=None,
        metavar="file",
        help="Configuration file path",
    )
    parser.add_argument(
        "module",
        default=None,
        nargs="?",
        help="Module name",
    )
    parser.add_argument(
        "opts",
        nargs=REMAINDER,
        help="Arguments of module",
    )


def default_argument_parser() -> ArgumentParser:
    parser = ArgumentParser(
        prog=PROG,
        description=DESCRIPTION,
        epilog=EPILOG,
        formatter_class=RawDescriptionHelpFormatter,
    )

    logging_group = parser.add_mutually_exclusive_group()
    logging_group.add_argument(
        "--colored-logging",
        "-c",
        action="store_true",
        default=False,
        help="Use colored logging",
    )
    logging_group.add_argument(
        "--simple-logging",
        "-s",
        action="store_true",
        default=False,
        help="Use simple logging",
    )

    parser.add_argument(
        "--severity",
        choices=SEVERITIES,
        default=DEFAULT_SEVERITY,
        help=f"Logging severity (default: '{DEFAULT_SEVERITY}')",
    )
    parser.add_argument(
        "--debug",
        "-d",
        action="store_true",
        default=False,
        help="Enable debugging mode and change logging severity to 'DEBUG'",
    )
    parser.add_argument(
        "--verbose",
        "-v",
        action="count",
        default=0,
        help="Be more verbose/talkative during the operation",
    )
    parser.add_argument(
        "--version",
        "-V",
        action="version",
        version=version(),
    )

    subparsers = parser.add_subparsers(dest="cmd")
    add_cmd1_parser(subparsers)
    add_cmd2_parser(subparsers)
    return parser


def get_default_arguments(
    cmdline: Optional[List[str]] = None,
    namespace: Optional[Namespace] = None,
) -> Namespace:
    parser = default_argument_parser()
    return parser.parse_known_args(cmdline, namespace)[0]

# -*- coding: utf-8 -*-

from argparse import REMAINDER, ArgumentParser, Namespace, RawDescriptionHelpFormatter
from functools import lru_cache
from typing import Final, List, Optional

from %PROJECT_LOWER%.logging.logging import SEVERITIES, SEVERITY_NAME_INFO

PROG: Final[str] = "%PROJECT_LOWER%"
DESCRIPTION: Final[str] = "%PROJECT_DESC%"
EPILOG: Final[str] = ""

CMD_CLIENT: Final[str] = "client"
CMD_CLIENT_HELP: Final[str] = ""
CMD_CLIENT_EPILOG: Final[str] = ""

CMD_SERVER: Final[str] = "server"
CMD_SERVER_HELP: Final[str] = ""
CMD_SERVER_EPILOG: Final[str] = ""

CMDS = (CMD_CLIENT, CMD_SERVER)

DEFAULT_SEVERITY: Final[str] = SEVERITY_NAME_INFO
DEFAULT_HOST: Final[str] = "localhost"
DEFAULT_BIND: Final[str] = "0.0.0.0"
DEFAULT_PORT: Final[int] = 8080
DEFAULT_TIMEOUT: Final[float] = 1.0


@lru_cache
def version() -> str:
    # [IMPORTANT] Avoid 'circular import' issues
    from scot import __version__

    return __version__


def add_client_parser(subparsers) -> None:
    # noinspection SpellCheckingInspection
    parser = subparsers.add_parser(
        name=CMD_CLIENT,
        help=CMD_CLIENT_HELP,
        formatter_class=RawDescriptionHelpFormatter,
        epilog=CMD_CLIENT_EPILOG,
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
        "--host",
        "-H",
        default=DEFAULT_HOST,
        metavar="host",
        help=f"Host address (default: '{DEFAULT_HOST}')",
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


def add_server_parser(subparsers) -> None:
    # noinspection SpellCheckingInspection
    parser = subparsers.add_parser(
        name=CMD_SERVER,
        help=CMD_SERVER_HELP,
        formatter_class=RawDescriptionHelpFormatter,
        epilog=CMD_SERVER_EPILOG,
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
        "--use-uvloop",
        action="store_true",
        default=False,
        help="Replace the event loop with uvloop",
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
    add_client_parser(subparsers)
    add_server_parser(subparsers)
    return parser


def get_default_arguments(
    cmdline: Optional[List[str]] = None,
    namespace: Optional[Namespace] = None,
) -> Namespace:
    parser = default_argument_parser()
    return parser.parse_known_args(cmdline, namespace)[0]

# -*- coding: utf-8 -*-

from argparse import Namespace
from typing import Callable, List, Optional

from %PROJECT_LOWER%.arguments import CMD1, CMD2, CMDS, get_default_arguments
from %PROJECT_LOWER%.logging.logging import (
    SEVERITY_NAME_DEBUG,
    logger,
    set_default_logging_config,
    set_root_level,
    set_simple_logging_config,
)


def cmd1_main(args: Namespace, printer: Callable[..., None] = print) -> int:
    assert args is not None
    assert printer is not None
    raise NotImplementedError


def cmd2_main(args: Namespace, printer: Callable[..., None] = print) -> int:
    assert args is not None
    assert printer is not None
    raise NotImplementedError


def main(
    cmdline: Optional[List[str]] = None,
    printer: Callable[..., None] = print,
) -> int:
    args = get_default_arguments(cmdline)

    if not args.cmd:
        printer("The command does not exist")
        return 1

    if args.default_logging and args.simple_logging:
        printer(
            "The 'default_logging' flag and the 'simple_logging' flag cannot coexist"
        )
        return 1

    cmd = args.cmd
    default_logging = args.default_logging
    simple_logging = args.simple_logging
    severity = args.severity
    debug = args.debug
    verbose = args.verbose

    assert cmd in CMDS
    assert isinstance(default_logging, bool)
    assert isinstance(simple_logging, bool)
    assert isinstance(severity, str)
    assert isinstance(debug, bool)
    assert isinstance(verbose, int)

    if default_logging:
        set_default_logging_config()
    elif simple_logging:
        set_simple_logging_config()

    if debug:
        set_root_level(SEVERITY_NAME_DEBUG)
    else:
        set_root_level(severity)

    logger.debug(f"Arguments: {args}")

    try:
        if cmd == CMD1:
            return cmd1_main(args, printer=printer)
        elif cmd == CMD2:
            return cmd2_main(args, printer=printer)
        else:
            assert False, "Inaccessible section"
    except BaseException as e:
        logger.exception(e)
        return 1


if __name__ == "__main__":
    exit(main())

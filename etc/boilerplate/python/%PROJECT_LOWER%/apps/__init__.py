# -*- coding: utf-8 -*-

from argparse import Namespace
from asyncio.exceptions import CancelledError
from functools import lru_cache

from %PROJECT_LOWER%.apps.client.main import client_main
from %PROJECT_LOWER%.apps.server.main import server_main
from %PROJECT_LOWER%.arguments import CMD_CLIENT, CMD_SERVER
from %PROJECT_LOWER%.logging.logging import logger


@lru_cache
def cmd_apps():
    return {
        CMD_CLIENT: client_main,
        CMD_SERVER: server_main,
    }


def run_app(cmd: str, args: Namespace) -> int:
    apps = cmd_apps()
    app = apps.get(cmd, None)
    if app is None:
        logger.error(f"Unknown app command: {cmd}")
        return 1

    try:
        app(args)
    except CancelledError:
        logger.debug("An cancelled signal was detected")
        return 0
    except KeyboardInterrupt:
        logger.warning("An interrupt signal was detected")
        return 0
    except Exception as e:
        logger.exception(e)
        return 1
    except BaseException as e:
        logger.exception(e)
        return 1
    else:
        return 0

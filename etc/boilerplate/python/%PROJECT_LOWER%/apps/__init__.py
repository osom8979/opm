# -*- coding: utf-8 -*-

from argparse import Namespace
from asyncio.exceptions import CancelledError

from %PROJECT_LOWER%.apps.client.main import client_main
from %PROJECT_LOWER%.apps.server.main import server_main
from %PROJECT_LOWER%.arguments import CMD_CLIENT, CMD_SERVER
from %PROJECT_LOWER%.logging.logging import logger

CMD2MAIN = {
    CMD_CLIENT: client_main,
    CMD_SERVER: server_main,
}


def run_app(cmd: str, args: Namespace, printer: Callable[..., None] = print) -> int:
    assert cmd in CMD2MAIN
    try:
        CMD2MAIN[cmd](args, printer)
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

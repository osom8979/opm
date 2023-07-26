# -*- coding: utf-8 -*-

from argparse import Namespace
from asyncio import run as asyncio_run
from asyncio.exceptions import CancelledError
from os import environ
from sys import version_info
from typing import Callable

if version_info >= (3, 11):
    from asyncio import Runner  # type: ignore[attr-defined]

from uvloop import install as uvloop_install
from uvloop import new_event_loop as uvloop_new_event_loop

from %PROJECT_LOWER%.logging.logging import logger


class DefaultApp:
    def __init__(
        self,
        api_token: str,
        server_address: str,
        *,
        use_uvloop=False,
        debug=False,
        verbose=0,
    ):
        self._api_token = api_token
        self._server_address = server_address
        self._use_uvloop = use_uvloop
        self._debug = debug
        self._verbose = verbose

    def run(self) -> int:
        try:
            if self._use_uvloop:
                if version_info >= (3, 11):
                    with Runner(loop_factory=uvloop_new_event_loop) as runner:
                        runner.run(self.run_until_complete())
                else:
                    uvloop_install()
                    asyncio_run(self.run_until_complete())
            else:
                asyncio_run(self.run_until_complete())
        except KeyboardInterrupt:
            logger.warning("An interrupt signal was detected")
            return 0
        except Exception as e:
            logger.exception(e)
            return 1
        else:
            return 0

    async def run_until_complete(self) -> None:
        await self.on_open()
        try:
            await self.on_main()
        except CancelledError:
            logger.debug("An cancelled signal was detected")
        finally:
            await self.on_close()

    async def on_open(self) -> None:
        pass

    async def on_close(self) -> None:
        pass

    async def on_main(self) -> None:
        pass


def _get_environment_value(key: str) -> str:
    value = environ.get(key, None)
    if not value:
        raise KeyError(f"The {key} environment variable is required")
    return value


def default_main(args: Namespace, printer: Callable[..., None] = print) -> int:
    assert args is not None
    assert printer is not None

    api_token = _get_environment_value("API_TOKEN")
    server_address = _get_environment_value("SERVER_ADDRESS")
    assert isinstance(args.use_uvloop, bool)
    assert isinstance(args.debug, bool)
    assert isinstance(args.verbose, int)

    app = DefaultApp(
        api_token=api_token,
        server_address=server_address,
        use_uvloop=args.use_uvloop,
        debug=args.debug,
        verbose=args.verbose,
    )
    return app.run()

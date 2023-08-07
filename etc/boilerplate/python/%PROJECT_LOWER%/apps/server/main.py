# -*- coding: utf-8 -*-

from argparse import Namespace
from asyncio import Task, create_task, shield
from contextlib import asynccontextmanager
from typing import Callable

from fastapi import APIRouter, FastAPI
from uvicorn import run as uvicorn_run

from %PROJECT_LOWER%.apps.app_base import AppBase
from %PROJECT_LOWER%.logging.logging import logger


class ServerApp(AppBase):
    _subtask: Task[None]

    def __init__(self, args: Namespace, printer: Callable[..., None] = print):
        super().__init__(args, printer)

        self._router = APIRouter()
        self._router.add_api_route("/health", self.health, methods=["GET"])

        self._app = FastAPI(lifespan=self._lifespan)
        self._app.include_router(self._router)

    @asynccontextmanager
    async def _lifespan(self, app: FastAPI):
        assert self._app == app
        self._subtask = create_task(self.subtask_main(), name="subtask")
        yield
        await shield(self._subtask)

    async def subtask_main(self) -> None:
        pass

    @property
    def router(self):
        return self._router

    @property
    def app(self):
        return self._app

    async def health(self):
        subtask_name = self._subtask.get_name()
        subtask_live = not self._subtask.done()
        return {
            "tasks": {
                subtask_name: subtask_live,
            }
        }

    def run(self) -> None:
        uvicorn_run(
            self._app,
            host=self.bind,
            port=self.port,
            lifespan="on",
            log_level=logger.level,
        )


def server_main(args: Namespace, printer: Callable[..., None] = print) -> None:
    app = ServerApp(args, printer)
    app.run()

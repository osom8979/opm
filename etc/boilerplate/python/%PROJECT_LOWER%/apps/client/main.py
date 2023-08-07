# -*- coding: utf-8 -*-

from argparse import Namespace
from typing import Callable

from %PROJECT_LOWER%.apps.app_base import AppBase


class ClientApp(AppBase):
    def __init__(self, args: Namespace, printer: Callable[..., None] = print):
        super().__init__(args, printer)

    def run(self) -> None:
        pass


def client_main(args: Namespace, printer: Callable[..., None] = print) -> None:
    app = ClientApp(args, printer)
    app.run()

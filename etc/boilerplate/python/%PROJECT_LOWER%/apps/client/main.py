# -*- coding: utf-8 -*-

from argparse import Namespace

from %PROJECT_LOWER%.apps.app_base import AppBase


class ClientApp(AppBase):
    def __init__(self, args: Namespace):
        super().__init__(args)

    def run(self) -> None:
        pass


def client_main(args: Namespace) -> None:
    app = ClientApp(args)
    app.run()

# -*- coding: utf-8 -*-

from argparse import Namespace
from typing import Callable


class AppBase:
    def __init__(self, args: Namespace, printer: Callable[..., None] = print):
        self._args = args
        self._printer = printer

        assert isinstance(args.debug, bool)
        assert isinstance(args.verbose, int)
        assert isinstance(args.use_uvloop, bool)

        self._debug = args.debug
        self._verbose = args.verbose
        self._use_uvloop = args.use_uvloop

    @property
    def args(self) -> Namespace:
        return self._args

    @property
    def debug(self) -> bool:
        return self._debug

    @property
    def verbose(self) -> int:
        return self._verbose

    @property
    def use_uvloop(self) -> bool:
        return self._use_uvloop

    @property
    def host(self) -> str:
        if hasattr(self._args, "host"):
            assert isinstance(self._args.host, str)
            return self._args.host
        else:
            return str()

    @property
    def bind(self) -> str:
        if hasattr(self._args, "bind"):
            assert isinstance(self._args.bind, str)
            return self._args.bind
        else:
            return str()

    @property
    def port(self) -> int:
        if hasattr(self._args, "port"):
            assert isinstance(self._args.port, int)
            return self._args.port
        else:
            return 0

    @property
    def timeout(self) -> float:
        if hasattr(self._args, "timeout"):
            assert isinstance(self._args.timeout, float)
            return self._args.timeout
        else:
            return 0.0

    def print(self, *args) -> None:
        self._printer(*args)

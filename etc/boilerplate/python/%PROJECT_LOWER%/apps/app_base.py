# -*- coding: utf-8 -*-

from argparse import Namespace
from typing import Any, Optional, Tuple

from %PROJECT_LOWER%.variables import PRINTER_NAMESPACE_ATTR_KEY


class AppBase:
    def __init__(self, args: Namespace):
        self._args = args

        assert isinstance(args.debug, bool)
        assert isinstance(args.verbose, int)
        assert isinstance(args.use_uvloop, bool)

        self._debug = args.debug
        self._verbose = args.verbose
        self._use_uvloop = args.use_uvloop

        assert hasattr(args, PRINTER_NAMESPACE_ATTR_KEY)
        self._printer = getattr(args, PRINTER_NAMESPACE_ATTR_KEY)

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

    @property
    def size(self) -> Optional[Tuple[int, int]]:
        if self._args.size is not None:
            assert isinstance(self._args.size, str)
            x, y = self._args.size.split("x")
            return int(x), int(y)
        else:
            return None

    def print(self, *args, **kwargs) -> Any:
        return self._printer(*args, **kwargs)

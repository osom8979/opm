# -*- coding: utf-8 -*-

from argparse import ArgumentParser, Namespace
from typing import Final, List, Optional

from aiohttp import web

PROG: Final[str] = "opy-aiohttp-echo-server"
DEFAULT_BIND: Final[str] = "localhost"
DEFAULT_PORT: Final[int] = 8080
DEFAULT_TIMEOUT: Final[float] = 8.0


@web.middleware
async def echo_middleware(request: web.BaseRequest, handler):
    method = request.method
    path = request.raw_path
    http_version = f"{request.version.major}.{request.version.minor}"
    print(f"{method} {path} {http_version}")
    for key in request.headers:
        print(f"{key}: {request.headers[key]}")
    data = await request.content.read()
    print(data)
    return web.Response(body=data, headers=request.headers)


def get_default_arguments(
    cmdline: Optional[List[str]] = None,
    namespace: Optional[Namespace] = None,
) -> Namespace:
    parser = ArgumentParser(prog=PROG)
    parser.add_argument(
        "--bind",
        "-b",
        default=DEFAULT_BIND,
        metavar="addr",
        help=f"Bind address (default: '{DEFAULT_BIND}')",
    )
    parser.add_argument(
        "--port",
        "-p",
        type=int,
        default=DEFAULT_PORT,
        metavar="port",
        help=f"Port number (default: {DEFAULT_PORT})",
    )
    parser.add_argument(
        "--timeout",
        "-t",
        default=DEFAULT_TIMEOUT,
        type=float,
        help=f"Request timeout in seconds (default: {DEFAULT_TIMEOUT})",
    )
    return parser.parse_known_args(cmdline, namespace)[0]


def init_default_app():
    app = web.Application(
        middlewares=[echo_middleware],
    )
    return app


def main():
    args = get_default_arguments()
    assert isinstance(args.bind, str)
    assert isinstance(args.port, int)
    assert isinstance(args.timeout, float)
    web.run_app(
        init_default_app(),
        host=args.bind,
        port=args.port,
        keepalive_timeout=args.timeout,
    )


if __name__ == "__main__":
    main()

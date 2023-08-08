# -*- coding: utf-8 -*-

from typing import Any

from orjson import dumps, loads


def orjson_byte_encoder(data: Any) -> bytes:
    return dumps(data)


def orjson_byte_decoder(data: bytes) -> Any:
    return loads(data)


def orjson_encoder(data: Any) -> str:
    return str(dumps(data), encoding="utf-8")


def orjson_decoder(data: str) -> Any:
    return loads(data)

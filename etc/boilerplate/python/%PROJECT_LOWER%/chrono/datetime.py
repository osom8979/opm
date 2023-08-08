# -*- coding: utf-8 -*-

from datetime import datetime


def tznow() -> datetime:
    return datetime.now().astimezone()

# -*- coding: utf-8 -*-

from datetime import date, datetime
from typing import Final, Tuple

YYYY_MM_DD_TEMPLATE: Final[str] = "YYYY-MM-DD"
YYYY_MM_DD_TEMPLATE_LEN: Final[int] = len(YYYY_MM_DD_TEMPLATE)
DEFAULT_DATE_SEPARATOR: Final[str] = "-"


def parse_yyyy_mm_dd(text: str, separator=DEFAULT_DATE_SEPARATOR) -> date:
    """
    Parse the format 'YYYY-MM-DD' as 'date'.
    """

    if len(text) != YYYY_MM_DD_TEMPLATE_LEN:
        _len = YYYY_MM_DD_TEMPLATE_LEN
        raise ValueError(f"The `text` argument must be {_len} characters long: {text}")
    if text[4] != separator:
        raise ValueError(f"The separator must be `{separator}`")
    if text[7] != separator:
        raise ValueError(f"The separator must be `{separator}`")

    yyyy = text[0:4]
    mm = text[5:7]
    dd = text[8:10]

    if not yyyy.isdigit():
        raise ValueError("The `yyyy` must be a digit")
    if not mm.isdigit():
        raise ValueError("The `mm` must be a digit")
    if not dd.isdigit():
        raise ValueError("The `dd` must be a digit")

    return date(year=int(yyyy), month=int(mm), day=int(dd))


def date_to_datetime_range(d: date) -> Tuple[datetime, datetime]:
    left = datetime(
        year=d.year,
        month=d.month,
        day=d.day,
        hour=0,
        minute=0,
        second=0,
        microsecond=0,
    )
    right = datetime(
        year=d.year,
        month=d.month,
        day=d.day,
        hour=23,
        minute=59,
        second=59,
        microsecond=999999,
    )
    return left, right

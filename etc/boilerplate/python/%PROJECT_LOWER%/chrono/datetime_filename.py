# -*- coding: utf-8 -*-

from datetime import datetime
from typing import Tuple

"""
'%Y'
    Year with century as a decimal number.
    e.g. 0001, 0002, …, 2013, 2014, …, 9998, 9999
'%m'
    Month as a zero-padded decimal number.
    e.g. 01, 02, …, 12
'%d'
    Day of the month as a zero-padded decimal number.
    e.g. 01, 02, …, 31
"""
DATETIME_TO_DIRECTORY_STRFTIME_FORMAT = "%Y-%m-%d"  # e.g. '2022-02-14'

"""
"%H'
    Hour (24-hour clock) as a zero-padded decimal number.
    e.g. 00, 01, …, 23
'%M'
    Minute as a zero-padded decimal number.
    e.g. 00, 01, …, 59
'%S'
    Second as a zero-padded decimal number.
    e.g. 00, 01, …, 59
'%f'
    Microsecond as a decimal number, zero-padded to 6 digits.
    e.g. 000000, 000001, …, 999999
"""
DATETIME_TO_FILENAME_STRFTIME_FORMAT = "%H_%M_%S.%f"  # e.g. '14_28_19.286335'


def parse_dirname_and_filename(time: datetime) -> Tuple[str, str]:
    directory = time.strftime(DATETIME_TO_DIRECTORY_STRFTIME_FORMAT)
    filename = time.strftime(DATETIME_TO_FILENAME_STRFTIME_FORMAT)
    return directory, filename

# -*- coding: utf-8 -*-

import os
import sys
from functools import lru_cache


@lru_cache
def get_assets_dir() -> str:
    # Check if `_MEIPASS` attribute is available in sys else return current file path
    return getattr(sys, "_MEIPASS", os.path.abspath(os.path.dirname(__file__)))

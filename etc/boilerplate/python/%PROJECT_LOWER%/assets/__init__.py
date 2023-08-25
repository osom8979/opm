# -*- coding: utf-8 -*-

import os
import sys
from functools import lru_cache


@lru_cache
def get_assets_dir() -> str:
    # Check if `_MEIPASS` attribute is available in sys else return current file path
    if hasattr(sys, "_MEIPASS"):
        return os.path.join(getattr(sys, "_MEIPASS"), "assets")
    else:
        return os.path.abspath(os.path.dirname(__file__))

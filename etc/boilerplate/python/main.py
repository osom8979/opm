# -*- coding: utf-8 -*-

import os
import sys

SOURCE_PATH = os.path.abspath(__file__)
SOURCE_DIR = os.path.dirname(SOURCE_PATH)

# Make it run even if you don't install it as a package.
os.chdir(SOURCE_DIR)
sys.path.append(SOURCE_DIR)

from %PROJECT_LOWER%.entrypoint import main  # noqa

if __name__ == "__main__":
    exit(main())

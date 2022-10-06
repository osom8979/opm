# -*- coding: utf-8 -*-

import os
from typing import List

from setuptools import setup

SOURCE_PATH = os.path.abspath(__file__)
SOURCE_DIR = os.path.dirname(SOURCE_PATH)
REQUIREMENTS_MAIN = os.path.join(SOURCE_DIR, "requirements.main.txt")
REQUIREMENTS_TEST = os.path.join(SOURCE_DIR, "requirements.test.txt")


def install_requires(path: str, encoding="utf-8") -> List[str]:
    with open(path, encoding=encoding) as f:
        content = f.read()
    lines0 = content.split("\n")
    lines1 = map(lambda x: x.strip(), lines0)
    lines2 = filter(lambda x: x and not x.startswith("#"), lines1)
    lines3 = filter(lambda x: x and not x.startswith("-"), lines2)
    return list(lines3)


if __name__ == "__main__":
    setup(
        install_requires=install_requires(REQUIREMENTS_MAIN),
        tests_require=install_requires(REQUIREMENTS_TEST),
    )

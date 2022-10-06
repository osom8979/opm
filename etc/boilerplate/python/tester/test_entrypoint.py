# -*- coding: utf-8 -*-

from contextlib import redirect_stdout
from io import StringIO
from typing import Optional
from unittest import TestCase, main

from %PROJECT_LOWER%.arguments import version
from %PROJECT_LOWER%.entrypoint import main as entrypoint_main


class EntrypointTestCase(TestCase):
    def test_version(self):
        buffer = StringIO()
        code: Optional[int] = None
        with redirect_stdout(buffer):
            try:
                entrypoint_main(["--version"])
            except SystemExit as e:
                code = e.code
        self.assertEqual(0, code)
        self.assertEqual(version(), buffer.getvalue().strip())


if __name__ == "__main__":
    main()

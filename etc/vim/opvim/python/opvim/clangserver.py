#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import signal

from clang import cindex
from neovim import attach

class ClangServer:
    """
    clang server.
    """

    path = str() # Use the ${NVIM_LISTEN_ADDRESS} of a running instance.
    nvim = object()
    is_running = False

    def __init__(self, path):
        self.path = path
        self.is_running = False

    def exit(self):
        self.is_running = False

    def run(self):
        self.nvim = attach('socket', path=self.path)
        cindex.Config.set_library_file(self.nvim.vars['opvim_libclang_path'])
        self.is_running = True

        while (self.is_running):
            event = self.nvim.next_message()
            if not event:
                continue

GLOBAL_CLANG_SERVER = object()

def signalHandler(signal, frame):
    if signal == signal.SIGINT or signal == signal.SIGKILL:
        GLOBAL_CLANG_SERVER.exit()

def startClangServer(path):
    signal.signal(signal.SIGINT, signalHandler)
    signal.signal(signal.SIGKILL, signalHandler)
    #signal.pause()
    return ClangServer(path).run()


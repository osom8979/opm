#!/usr/bin/env python
# -*- coding: utf-8 -*-

import commands
import optparse
import shlex
import threading
import lldb
from neovim import attach


class BackgroundServer:
    """
    LLDB Background Server.
    """

    is_running = False
    nvim = object()

    def __init__(self, options):
        self.nvim = attach('socket', path=options.socket)
        self.nvim.command('echo "Connect LLDB background server!"')

    def run(self):
        self.is_running = True
        while self.is_running:
            message = self.nvim.next_message()
            if not message:
                continue

            command = message[1]

            if command == 'exit':
                is_running = False
            else:
                self.nvim.command('echo "Unknown command: {}"'.format(command))

        self.nvim.command('echo "LLDB background server Done!"')
        pass

def onBackgroundServer(options):
    server = BackgroundServer(options)
    server.run()

def createOptionParser():
    parser = optparse.OptionParser(add_help_option=False)
    parser.add_option('-s', '--socket', type='string', dest='socket', help='Neovim socket path')
    return parser

def init(debugger, command, result, internal_dict):
    #target = debugger.GetSelectedTarget()
    #process = target.GetProcess()
    #thread = process.GetSelectedThread()

    try:
        (options, args) = createOptionParser().parse_args(shlex.split(command))
    except:
        # If you don't handle exceptions,
        # passing an incorrect argument to the OptionParser will cause LLDB to exit
        result.SetError("Option parsing failed.")
        return

    if not options.socket:
        result.SetError("Not defined socket path.")
        return

    t = threading.Thread(target=server, args=(options,))
    t.start()


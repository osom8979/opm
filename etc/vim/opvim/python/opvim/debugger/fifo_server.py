#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import print_function

import os
import sys
import signal
import optparse
import json

from neovim import attach

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

class FifoServer:

    fifo_path = str()
    nvim_socket_path = str()

    def __init__(self, fifo_path, nvim_socket_path):
        self.fifo_path = fifo_path
        self.nvim_socket_path = nvim_socket_path

        self.fifo = open(self.fifo_path)
        if not self.fifo:
            raise 'FIFO open error: ' + self.fifo_path

        self.nvim = attach('socket', path=self.nvim_socket_path)
        if not self.nvim:
            raise 'nvim attach error: ' + self.nvim_socket_path

    def exit(self):
        self.fifo.write('{"kill":1}')

    def run(self):
        is_running = True
        while is_running:
            message = self.fifo.read()
            if not message:
                continue
            is_running = self.onEvent(message)

        self.fifo.close()
        return True

    def onEvent(self, message):
        try:
            json_data = json.loads(json.dumps(message))
        except json.decoder.JSONDecodeError as err:
            json_data = dict()
        except:
            json_data = dict()

        if 'kill' in json_data:
            return False
        return True

def createOptionParser():
    parser = optparse.OptionParser(add_help_option=False)
    parser.add_option('-f', '--fifo', type='string', dest='fifo', help='FIFO path')
    parser.add_option('-n', '--nvim', type='string', dest='nvim', help='NeoVim socket path')
    return parser

def main():
    try:
        (options, args) = createOptionParser().parse_args(sys.argv)
    except:
        raise "Option parsing failed."

    if not options.fifo:
        raise "Not defined fifo path."
    if not options.nvim:
        raise "Not defined nvim socket path."

    global fifo_server
    fifo_server = FifoServer(options.fifo, options.nvim)

    signal.signal(signal.SIGTERM, lambda s, f: fifo_server.exit())

    return fifo_server.run()

if __name__ == '__main__':
    if main():
        result_code = 0
    else:
        result_code = 1

    sys.stdout.flush()
    exit(result_code)


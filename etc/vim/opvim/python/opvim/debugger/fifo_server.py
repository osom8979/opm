#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import signal
import optparse
import shlex
import json

from neovim import attach

class FifoServer:
    """
    LLDB Background Server.
    """

    fifo_path = str()
    nvim_socket_path = str()

    fifo = object()
    nvim = object()

    def __init__(self, fifo_path, nvim_socket_path):
        self.fifo_path = fifo_path
        self.nvim_socket_path = nvim_socket_path

    def exit(self):
        self.fifo.write('{"kill":1}')

    def run(self):
        self.fifo = open(self.fifo)
        if not self.fifo:
            return False

        self.nvim = attach('socket', path=self.nvim_socket_path)
        if not self.nvim:
            return False

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
            #print('JSON Decode Error: {}'.format(err))
            json_data = dict()
        except:
            #print('Unknown message Error')
            json_data = dict()

        if 'kill' in json_data:
            return False
        return True

global fifo_server
fifo_server = object()

def onJobStopCallback(signum, frame):
    fifo_server.exit()

def createOptionParser():
    parser = optparse.OptionParser(add_help_option=False)
    parser.add_option('-f', '--fifo', type='string', dest='fifo', help='FIFO path')
    parser.add_option('-n', '--nvim', type='string', dest='nvim', help='NeoVim socket path')
    return parser

def main():
    try:
        (options, args) = createOptionParser().parse_args(shlex.split(command))
    except:
        raise "Option parsing failed."

    if not options.fifo:
        result.SetError("Not defined fifo path.")
    if not options.nvim:
        result.SetError("Not defined nvim socket path.")

    signal.signal(signal.SIGINT, onJobStopCallback)
    signal.signal(signal.SIGTERM, onJobStopCallback)

    fifo_server = FifoServer(options.fifo, options.nvim)
    return fifo_server.run()

if __name__ == '__main__':
    main()


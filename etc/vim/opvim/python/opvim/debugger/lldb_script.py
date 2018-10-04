#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import errno
import optparse
import shlex
import threading
import json
import lldb

# Don't use neovim package.
# (Not working in MacOS system python)

class BackgroundServer:
    """
    LLDB Background Server.
    """

    fifo_path = str()
    fifo = object()

    def __init__(self, fifo_path):
        self.fifo_path = fifo_path

    def exit(self):
        self.fifo.write('{"kill":1}')

    def run(self):
        self.fifo = open(self.fifo_path)
        if not self.fifo:
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

def onBackgroundServer(fifo_path):
    server = BackgroundServer(fifo_path)
    server.run()

def createOptionParser():
    parser = optparse.OptionParser(add_help_option=False)
    parser.add_option('-f', '--fifo', type='string', dest='fifo', help='FIFO path')
    return parser

def init(debugger, command, result, internal_dict):
    #target = debugger.GetSelectedTarget()
    #process = target.GetProcess()
    #thread = process.GetSelectedThread()

    try:
        (options, args) = createOptionParser().parse_args(shlex.split(command))
    except:
        result.SetError("Option parsing failed.")
        return

    if not options.fifo:
        result.SetError("Not defined fifo path.")
        return

    t = threading.Thread(target=onBackgroundServer, args=(options.fifo,))
    t.start()


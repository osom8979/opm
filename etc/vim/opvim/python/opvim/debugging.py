#!/usr/bin/env python
# -*- coding: utf-8 -*-

from .common import *
import os
import sys
import vim


class DebuggingError(Exception):
    """
    Base class for exceptions in this module.
    """

    message = str()

    def __init__(self, message):
        self.message = message

class ParseError(DebuggingError):

    def __init__(self, expression):
        super.__init__('Parse error: {}'.format(expression))

class EmptyStringError(DebuggingError):

    def __init__(self, expression):
        super.__init__('Empty string error: {}'.format(expression))


class Debugging:
    """
    opm-vim debugging class.
    """

    debug_type = str()
    debug_cwd = str()
    debug_cmds = str()

    def __init__(self, debug_type, debug_cwd, debug_cmds):
        if not debug_type:
            raise EmptyStringError('type')
        if not debug_cwd:
            raise EmptyStringError('cwd')
        if not debug_cmds:
            raise EmptyStringError('cmds')

        self.debug_type = getCheckedDebugType(debug_type)
        if not self.debug_type:
            raise ParseError(debug_type)

        self.debug_cwd = debug_cwd
        self.debug_cmds = debug_cmds

    def preview(self):
        print('type: {}'.format(self.debug_type))
        print('cwd: {}'.format(self.debug_cwd))
        print('cmds: {}'.format(self.debug_cmds))
        pass

    def run(self):
        if getDebuggingPreview():
            self.preview()

        height = getDebuggingWindowHeight()
        cwd = self.debug_cwd
        program = self.debug_type
        args = self.debug_cmds

        for w in vim.windows:
            print('buffers: '.format(w.buffer.name))

        #command('{}split term://{}//{} {} | startinsert'.format(height, cwd, program, args))
        print('END')

        #command('tabnew')   # Create new tab for the debugging view
        #command('split')    # create horizontal split to display the current file
        #command('wincmd j') # go to the bottom window and spawn gdb client

        pass


def getDebugging(debug_type, debug_cwd, debug_cmds):
    return Debugging(debug_type, debug_cwd, debug_cmds)


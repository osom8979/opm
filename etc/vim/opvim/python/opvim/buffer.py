#!/usr/bin/env python
# -*- coding: utf-8 -*-

from .common import *
import os
import re

class Buffer:
    """
    vim buffer information.
    """

    index = 0
    f1 = ' '
    f2 = ' '
    f3 = ' '
    f4 = ' '
    f5 = ' '
    name = str()
    line = 0

    def __init__(self, line=str()):
        if not line:
            return
        self.index = int(line[0:3].strip())
        self.f1 = line[3]
        self.f2 = line[4]
        self.f3 = line[5]
        self.f4 = line[6]
        self.f5 = line[7]
        # line[8] is space(' ') string.
        line_start_index = line.rfind('line')
        self.name = line[9:line_start_index].strip()[1:-1] # remove quoting
        self.line = int(line[line_start_index+4:].strip()) # obtain integer

    def isUnlisted(self):
        """
        an unlisted buffer (only displayed when [!] is used) |unlisted-buffer|
        """
        return self.f1 is 'u'

    def isListed(self):
        return not self.unlisted()

    def isCurrent(self):
        """ the buffer in the current window """
        return self.f2 is '%'

    def isAlternate(self):
        """ the alternate buffer for ":e #" and CTRL-^ """
        return self.f2 is '#'

    def isActive(self):
        """ an active buffer: it is loaded and visible """
        return self.f3 is 'a'

    def isHidden(self):
        """
        a hidden buffer: It is loaded, but currently not displayed in a window |hidden-buffer|
        """
        return self.f3 is 'h'

    def isInactive(self):
        """ displayed in window(no) & loaded(no) """
        return self.f3 is ' '

    def isNoModifiable(self):
        """ a buffer with 'modifiable' off """
        return self.f4 is '-'

    def isReadonly(self):
        """ a readonly buffer """
        return self.f4 is '='

    def isTerminalRunning(self):
        """ a terminal buffer with a running job """
        return self.f4 is 'R'

    def isTerminalFinished(self):
        """ a terminal buffer with a finished job """
        return self.f4 is 'F'

    def isTerminalWithout(self):
        """ a terminal buffer without a job: `:terminal NONE` """
        return self.f4 is '?'

    def isModified(self):
        """ a modified buffer """
        return self.f5 is '+'

    def isReadError(self):
        """ a buffer with read errors """
        return self.f5 is 'x'

    def __str__(self):
        return '{:3d}{}{}{}{}{} "{}" line {}'.format(self.index,
                self.f1, self.f2, self.f3, self.f4, self.f5,
                self.name, self.line)

def getBufferList():
    result = list()
    for line in getCommandOutput('buffers!').split('\n'):
        if line:
            result.append(Buffer(line))
    return result


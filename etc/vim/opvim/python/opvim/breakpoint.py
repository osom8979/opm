#!/usr/bin/env python
# -*- coding: utf-8 -*-

from .common import *
import os

SPLIT_KEY = '\t'

BREAK_UNKNOWN_TYPE = 0
BREAK_FILE_TYPE = 1

class Breakpoint:
    """
    Single breakpoint information.
    """

    break_number = 0
    file_name = str()
    line_number = int()
    is_enable = True
    break_type = BREAK_UNKNOWN_TYPE
    condition = str()

    def __init__(self, file_name, line_number, is_enable=True):
        self.file_name = file_name
        self.line_number = line_number
        self.is_enable = is_enable

    def __str__(self):
        return self.file_name + SPLIT_KEY + self.line_number

    def parse(self, breakpoint_string):
        split = breakpoint_string.split(SPLIT_KEY)
        self.file_name = split[0]
        self.line_number = int(split[1])

    def exists(self):
        return os.path.isfile(self.file_name)

    def jump(self):
        command(':edit +{} {}'.format(self.line_number, self.file_name))

    def getGDBCommand(self):
        return 'break {}:{}'.format(self.file_name, self.line_number)

    def getLLDBCommand(self):
        return 'breakpoint set --file {} --line {}'.format(self.file_name, self.line_number)


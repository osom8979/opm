#!/usr/bin/env python
# -*- coding: utf-8 -*-

from .config import *

__add__ = ['init', 'execute', 'cmake', 'build', 'debug', 'test', 'open', 'preview']

def init():
    config.initGlobalVariables()
    return True

def execute(flags):
    config.execute(flags)

def cmake(flags):
    pass

def build(flags):
    pass

def debug(flags):
    pass

def test(flags):
    pass

def open(flags):
    pass

def preview():
    config.preview()


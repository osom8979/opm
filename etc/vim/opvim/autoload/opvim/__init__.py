#!/usr/bin/env python
# -*- coding: utf-8 -*-

from .common import *
from .project import *

__add__ = ['init', 'preview', 'execute', 'autoMode']

def init():
    common.setDefaultCMakeWhich()

def preview():
    project.previewGlobalProject()

def execute(flags):
    common.execute(flags)

def autoMode():
    mode = project.getFirstMode()
    if mode is None:
        mode = getDefaultProjectMode()
        print('Not found project-mode.')
        print('Set to default project-mode: {}'.format(mode))
    common.setProjectMode(mode)

def cmake(flags):
    common.cmake(flags)
    pass

# def build(flags):
#     pass
#
# def debug(flags):
#     pass
#
# def test(flags):
#     pass


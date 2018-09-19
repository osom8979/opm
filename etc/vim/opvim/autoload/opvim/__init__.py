#!/usr/bin/env python
# -*- coding: utf-8 -*-

from .common import *
from .project import *

__add__ = ['init', 'preview', 'execute']

def init():
    common.setDefaultCMakeWhich()

def preview():
    project.previewGlobalProject()

def execute(flags):
    common.execute(flags)

# def cmake(flags):
#     common.cmake(flags)
#     pass
#
# def build(flags):
#     pass
#
# def debug(flags):
#     pass
#
# def test(flags):
#     pass


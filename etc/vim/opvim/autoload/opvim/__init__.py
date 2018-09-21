#!/usr/bin/env python
# -*- coding: utf-8 -*-

from .common import *
from .project import *

import os

__add__ = ['init', 'preview', 'execute', 'autoMode', 'cmake', 'build']

def init():
    common.setDefaultCMakeWhich()

def preview(show_error=True):
    project.previewDefaultProject(show_error)

def execute(flags):
    common.execute(flags)

def autoMode():
    mode = project.getFirstMode()
    if mode is None:
        mode = getDefaultProjectMode()
        print('Not found project-mode.')
        print('Set to default project-mode: {}'.format(mode))
    common.setProjectMode(mode)

def cmake():
    proj = project.getDefaultProject()
    if not proj.exists():
        common.eprint('Project is not exists.')
        return
    if not proj.existsCurrentMode():
        common.eprint('{} mode is not exists.'.format(proj.mode))
        return

    root_dir = proj.getRoot()
    cmake_dir = os.path.join(root_dir, proj.getCurrentCMakeDirectory())
    cmake_flags = proj.getCurrentCMakeFlags()

    if not os.path.isdir(cmake_dir):
        os.mkdir(cmake_dir)

    cmds = '-cwd={}'.format(cmake_dir)
    cmds += ' {} {} {}'.format(common.getCMakePath(), cmake_flags, root_dir)
    common.execute(cmds)

def build(target=str()):
    proj = project.getDefaultProject()
    if not proj.exists():
        common.eprint('Project is not exists.')
        return
    if not proj.existsCurrentMode():
        common.eprint('{} mode is not exists.'.format(proj.mode))
        return

    root_dir = proj.getRoot()
    cmake_dir = os.path.join(root_dir, proj.getCurrentCMakeDirectory())
    build_flags = proj.getCurrentBuildFlags()

    cmds = '-cwd={}'.format(cmake_dir)
    cmds += ' {} --build {}'.format(common.getCMakePath(), cmake_dir)
    if target:
        cmds += ' --target {}'.format(target)
    cmds += ' -- {}'.format(build_flags)
    common.execute(cmds)

# def debug(flags):
#     pass
#
# def test(flags):
#     pass


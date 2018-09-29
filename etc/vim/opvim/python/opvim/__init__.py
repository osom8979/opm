#!/usr/bin/env python
# -*- coding: utf-8 -*-

from .common import *
from .project import *
from .debugging import *

import os

__add__ = ['init', 'preview', 'execute', 'autoMode', 'cmake', 'build', 'debug', 'script',
           'updateQuickMenu', 'updateQuickMenuMode']

def defaultProject():
    proj = project.getDefaultProject()
    if not proj.exists():
        common.eprint('Project is not exists.')
        return None
    if not proj.existsCurrentMode():
        common.eprint('{} mode is not exists.'.format(proj.mode))
        return None
    return proj

def init():
    common.setDefaultCMakeWhich()

def preview(show_error=True):
    project.previewDefaultProject(show_error)

def execute(flags):
    common.execute(flags)

def command(flags):
    common.command(flags)

def autoMode():
    mode = project.getFirstMode()
    if mode is None:
        mode = getDefaultProjectMode()
        print('Not found project-mode.')
        print('Set to default project-mode: {}'.format(mode))
    common.setProjectMode(mode)

def cmake():
    proj = defaultProject()
    if not proj:
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
    proj = defaultProject()
    if not proj:
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

def debug(debug_key):
    proj = defaultProject()
    if not proj:
        return

    debug_type = proj.getDebugType(debug_key)
    if not debug_type:
        common.eprint('Unknown {} type'.format(debug_type))
        return

    debug_cwd = proj.getDebugCwd(debug_key)
    if not os.path.isdir(debug_cwd):
        common.eprint('No such directory: {}'.format(debug_cwd))
        return

    debug_cmds = proj.getDebugCmds(debug_key)
    if not debug_cmds:
        common.eprint('Undefined cmd')
        return

    debugging.getDebugging(debug_type, debug_cwd, debug_cmds).run()

def script(script_key):
    proj = defaultProject()
    if not proj:
        return

    script_cwd = proj.getScriptCwd(script_key)
    if not os.path.isdir(script_cwd):
        common.eprint('No such directory: {}'.format(script_cwd))
        return

    script_cmds = proj.getScriptCmds(script_key)
    if not script_cmds:
        common.eprint('Undefined cmd')
        return

    cmds = '-cwd={}'.format(script_cwd)
    cmds += ' {}'.format(script_cmds)
    common.execute(cmds)

def appendQuickMenuSection(title):
    common.command('call quickmenu#append("# {}", "")'.format(title))

def appendQuickMenu(text, action, options):
    common.command('call quickmenu#append("{}", "{}", "{}")'.format(text, action, options))

def updateQuickMenu():
    proj = project.getDefaultProject()
    if not proj.exists() or not proj.existsCurrentMode():
        # Don't print to stderr.
        return

    validated_keys = list()
    for key in proj.getDebugKeys():
        if proj.getDebugType(key) and proj.getDebugCmds(key):
            validated_keys.append(key)

    appendQuickMenuSection('DEBUG')
    for vkey in validated_keys:
        appendQuickMenu(vkey, 'OpvimDebug ' + vkey, 'Run debugger ' + vkey)

    validated_keys = list()
    for key in proj.getScriptKeys():
        if proj.getScriptCmds(key):
            validated_keys.append(key)

    appendQuickMenuSection('SCRIPT')
    for vkey in validated_keys:
        appendQuickMenu(vkey, 'OpvimScript ' + vkey, 'Run script ' + vkey)

def updateQuickMenuMode():
    proj = project.getDefaultProject()
    for mode in proj.getModes():
        appendQuickMenu(mode, 'OpvimMode ' + mode, 'Change {} mode'.format(mode))


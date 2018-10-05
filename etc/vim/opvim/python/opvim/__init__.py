#!/usr/bin/env python
# -*- coding: utf-8 -*-

from .common import *
from .project import *
from .debugging import *

import os

__add__ = ['init', 'preview', 'execute', 'setMode', 'getMode', 'cmake', 'build', 'debug', 'script',
           'updateQuickMenu', 'updateQuickMenuMode', 'onFifoLogging']

def defaultProject():
    proj = project.getDefaultProject()
    if not proj.exists():
        common.eprint('Project is not exists.')
        return None
    if not proj.existsCurrentMode():
        common.eprint('{} mode is not exists.'.format(proj.getMode()))
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

def setMode(mode=str()):
    proj = project.getDefaultProject()
    if mode:
        proj.setMode(mode)
    else:
        proj.setAutoMode()

def getMode():
    return project.getDefaultProject().getMode()

def cmake():
    proj = defaultProject()
    if not proj:
        return

    root_dir = proj.getRoot()
    cmake_dir = os.path.join(root_dir, proj.getCurrentCMakeDirectory())
    cmake_flags = proj.getCurrentCMakeFlags()

    if not os.path.isdir(cmake_dir):
        os.mkdir(cmake_dir)

    cmds = str()
    if cmake_dir:
        cmds += ' -cwd={}'.format(cmake_dir)
    cmds += ' {} {} {}'.format(common.getCMakePath(), cmake_flags, root_dir)
    common.execute(cmds)

def build(target=str()):
    proj = defaultProject()
    if not proj:
        return

    root_dir = proj.getRoot()
    cmake_dir = os.path.join(root_dir, proj.getCurrentCMakeDirectory())
    build_flags = proj.getCurrentBuildFlags()

    cmds = str()
    if cmake_dir:
        cmds += ' -cwd={}'.format(cmake_dir)
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
    debug_cmds = proj.getDebugCmds(debug_key)
    if not debug_cmds:
        common.eprint('Undefined cmd')
        return

    debugging.startDebugging(debug_type, debug_cwd, debug_cmds)

def script(script_key):
    proj = defaultProject()
    if not proj:
        return

    script_cwd = proj.getScriptCwd(script_key)
    script_cmds = proj.getScriptCmds(script_key)
    if not script_cmds:
        common.eprint('Undefined cmd')
        return

    cmds = str()
    if script_cwd:
        cmds += ' -cwd={}'.format(script_cwd)
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

def onFifoLogging(log_prefix, message):
    if not message:
        return

    final_message = message

    setting_dir = common.getProjectSettingDir()
    fifo_name = common.getDebuggingFifoName()
    log_name = fifo_name + '.log'
    log_path = os.path.join(setting_dir, log_name)

    with open(log_path, 'a') as f:
        f.write(log_prefix + final_message)


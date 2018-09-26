#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import print_function

import os
import sys
import vim
import json
import pprint

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

def command(flags):
    vim.command(flags)

def getCurrentWorkingDirectory():
    return os.getcwd()

def which(name):
    for path in os.environ["PATH"].split(os.pathsep):
        if os.path.exists(os.path.join(path, name)):
            return os.path.join(path, name)
    return None

def whichCMakePath():
    return which('cmake')

def setCMakeWhich(cmake_path):
    vim.vars['opvim_cmake_which'] = cmake_path

def setDefaultCMakeWhich():
    setCMakeWhich(whichCMakePath())

def getCMakePath():
    return vim.vars['opvim_cmake_path']

def getProjectJsonName():
    return vim.vars['opvim_project_json_name']

def getDefaultProjectJsonPath():
    return os.path.join(getCurrentWorkingDirectory(), getProjectJsonName())

def getProjectMode():
    return vim.vars['opvim_project_mode']

def setProjectMode(mode):
    vim.vars['opvim_project_mode'] = mode

def getDefaultProjectMode():
    return vim.vars['opvim_default_project_mode']

def getDefaultBuildPrefix():
    return vim.vars['opvim_default_build_prefix']

def getDebuggingPreview():
    return int(vim.vars['opvim_debugging_preview']) is 1

def getDebuggingWindowHeight():
    return int(vim.vars['opvim_debugging_window_height'])

def execute(cmd):
    command(':AsyncRun {}'.format(cmd))

def executeSync(cmd):
    command(':cexpr system("{}")'.format(cmd))

DEBUG_TYPE_GDB = 'gdb'
DEBUG_TYPE_LLDB = 'lldb'
DEBUG_TYPE_PDB = 'pdb'

def getCheckedDebugType(debug_type):
    lower_type = debug_type.lower()
    if lower_type == DEBUG_TYPE_GDB:
        return DEBUG_TYPE_GDB
    elif lower_type == DEBUG_TYPE_LLDB:
        return DEBUG_TYPE_LLDB
    elif lower_type == DEBUG_TYPE_PDB:
        return DEBUG_TYPE_PDB
    return str()



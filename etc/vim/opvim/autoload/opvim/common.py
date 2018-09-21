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
    command('let g:opvim_cmake_which = "{}"'.format(cmake_path))

def setDefaultCMakeWhich():
    setCMakeWhich(whichCMakePath())

def getCMakePath():
    return vim.eval('g:opvim_cmake_path')

def getProjectJsonName():
    return vim.eval('g:opvim_project_json_name')

def getDefaultProjectJsonPath():
    return os.path.join(getCurrentWorkingDirectory(), getProjectJsonName())

def getProjectMode():
    return vim.eval('g:opvim_project_mode')

def setProjectMode(mode):
    command('let g:opvim_project_mode = "{}"'.format(mode))

def getDefaultProjectMode():
    return vim.eval('g:opvim_default_project_mode')

def getDefaultBuildPrefix():
    return vim.eval('g:opvim_default_build_prefix')

def execute(cmd):
    command(':AsyncRun {}'.format(cmd))

def executeSync(cmd):
    command(':cexpr system("{}")'.format(cmd))


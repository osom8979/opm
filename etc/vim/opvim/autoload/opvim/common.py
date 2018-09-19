#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import vim
import json
import pprint

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
    vim.command('let g:opvim_cmake_which = "{}"'.format(cmake_path))

def setDefaultCMakeWhich():
    setCMakeWhich(whichCMakePath())

def isAsyncEnable():
    return int(vim.eval('g:opvim_asyncrun_enable')) is 1

def getProjectJsonName():
    return vim.eval('g:opvim_project_json_name')

def getDefaultProjectJsonPath():
    return os.path.join(getCurrentWorkingDirectory(), getProjectJsonName())

def getProjectMode():
    return vim.eval('g:opvim_project_mode')

def getCMakeGenerator():
    return vim.eval('g:opvim_cmake_generator')

def execute(cmd):
    if isAsyncEnable():
        vim.command(':AsyncRun {}'.format(cmd))
    else:
        vim.command(':cexpr system("{}")'.format(cmd))


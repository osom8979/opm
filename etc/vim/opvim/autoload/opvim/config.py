#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import vim
import json
import pprint

def getWorkingDirectory():
    return os.getcwd()

def which(name):
    for path in os.environ["PATH"].split(os.pathsep):
        if os.path.exists(os.path.join(path, name)):
            return os.path.join(path, name)
    return None

def whichCMakePath():
    return which('cmake') 

def initGlobalVariables():
    vim.command('let g:opvim_cmake_which = "{}"'.format(whichCMakePath()))

def openProject(json_path):
    if not os.path.isfile(json_path):
        #print('Not found file: {}'.format(json_path))
        return None

    try:
        with open(json_path) as f:
            return json.load(f)
    except IOError:
        #print('File IO Error: {}'.format(json_path))
        pass

    return None

def openDefaultProject():
    return openProject(os.path.join(os.getcwd(), vim.eval('g:opvim_project_name')))

def execute(cmd):
    if int(vim.eval('g:opvim_asyncrun_enable')) == 1:
        vim.command(':AsyncRun {}'.format(cmd))
    else:
        vim.command(':cexpr system("{}")'.format(cmd))

def preview():
    print('Project mode: {}'.format(vim.eval('g:opvim_project_mode')))
    json_data = openDefaultProject()
    if json_data is not None:
        pprint.pprint(json_data)
    else:
        print('Project data is null')



#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import print_function

import os
import sys
import vim
import json

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

def getCurrentWorkingDirectory():
    return os.getcwd()

def which(name):
    for path in os.environ["PATH"].split(os.pathsep):
        if os.path.exists(os.path.join(path, name)):
            return os.path.join(path, name)
    return None

def whichCMakePath():
    return which('cmake')

def setGlobalVariable(key, value):
    vim.vars[key] = value

def getGlobalVariable(key):
    return vim.vars[key]

def getGlobalInteger(key):
    return int(getGlobalVariable(key))

# --------------
# CMAKE settings
# --------------

GLOBAL_KEY_CMAKE_WHICH = 'opvim_cmake_which'
GLOBAL_KEY_CMAKE_PATH  = 'opvim_cmake_path'

def setCMakeWhich(cmake_path):
    setGlobalVariable(GLOBAL_KEY_CMAKE_WHICH, cmake_path)

def setDefaultCMakeWhich():
    setCMakeWhich(whichCMakePath())

def getCMakePath():
    return getGlobalVariable(GLOBAL_KEY_CMAKE_PATH)

# ----------------
# PROJECT settings
# ----------------

GLOBAL_KEY_PROJECT_JSON_NAME        = 'opvim_project_json_name'
GLOBAL_KEY_PROJECT_SETTING_DIR_NAME = 'opvim_project_setting_dir_name'
GLOBAL_KEY_DEFAULT_BUILD_PREFIX     = 'opvim_default_build_prefix'
GLOBAL_KEY_PROJECT_CACHE_JSON_NAME  = 'opvim_project_cache_json_name'

def getProjectJsonName():
    return getGlobalVariable(GLOBAL_KEY_PROJECT_JSON_NAME)

def getDefaultProjectJsonPath():
    return os.path.join(getCurrentWorkingDirectory(), getProjectJsonName())

def getProjectSettingDirName():
    return getGlobalVariable(GLOBAL_KEY_PROJECT_SETTING_DIR_NAME)

def getProjectSettingDir():
    return os.path.join(getCurrentWorkingDirectory(), getProjectSettingDirName())

def getDefaultBuildPrefix():
    return getGlobalVariable(GLOBAL_KEY_DEFAULT_BUILD_PREFIX)

def getProjectCacheJsonName():
    return getGlobalVariable(GLOBAL_KEY_PROJECT_CACHE_JSON_NAME)

# ------------------
# DEVELOPER settings
# ------------------

GLOBAL_KEY_DEVELOPER_DEBUGGING = 'opvim_developer_debug'

def isDeveloperDebug():
    return getGlobalInteger(GLOBAL_KEY_DEVELOPER_DEBUGGING) is not 0

# -----------------
# QUICKFIX settings
# -----------------

GLOBAL_KEY_SHOW_QUICKFIX_IF_EXECUTE = 'show_quickfix_if_execute'

def isShowQuickfixIfExecute():
    return getGlobalInteger(GLOBAL_KEY_SHOW_QUICKFIX_IF_EXECUTE) is not 0

# ------------------
# DEBUGGING settings
# ------------------

GLOBAL_KEY_DEBUGGING_WINDOW_HEIGHT  = 'opvim_debugging_window_height'
GLOBAL_KEY_DEBUGGING_SCRIPT_NAME    = 'opvim_debugging_script_name'
GLOBAL_KEY_DEBUGGING_FIFO_NAME      = 'opvim_debugging_fifo_name'
GLOBAL_KEY_DEBUGGING_FIFO_SERVER_ID = 'opvim_debugging_fifo_server_id'

def getDebuggingWindowHeight():
    return getGlobalInteger(GLOBAL_KEY_DEBUGGING_WINDOW_HEIGHT)

def getDebuggingScriptName():
    return getGlobalVariable(GLOBAL_KEY_DEBUGGING_SCRIPT_NAME)

def getDebuggingFifoName():
    return getGlobalVariable(GLOBAL_KEY_DEBUGGING_FIFO_NAME)

def getDebuggingFifoServerId():
    return getGlobalVariable(GLOBAL_KEY_DEBUGGING_FIFO_SERVER_ID)

def setDebuggingFifoServerId(value):
    setGlobalVariable(GLOBAL_KEY_DEBUGGING_FIFO_SERVER_ID, value)

# -----------
# VIM COMMAND
# -----------

def evaluate(expression):
    """
    Evaluates the expression str using the vim internal expression
    evaluator (see |expression|).  Returns the expression result as:
    - a string if the Vim expression evaluates to a string or number
    - a list if the Vim expression evaluates to a Vim list
    - a dictionary if the Vim expression evaluates to a Vim dictionary
    Dictionaries and lists are recursively expanded.
    """
    return vim.eval(expression)

def command(flags):
    """
    Executes the vim (ex-mode) command str. Returns None.
    """
    vim.command(flags)

def getCommandOutput(flags):
    """
    Executes the vim (ex-mode) command str. Returns None.
    """
    vim.command("silent exec 'redir @\" | {} | redir END'".format(flags))
    return vim.eval('@"')

def execute(cmd):
    command(':AsyncRun {}'.format(cmd))
    if isShowQuickfixIfExecute():
        command('if exists("*ToggleQuickfixBuffer") | call ToggleQuickfixBuffer(1) | else | silent execute "belowright copen | wincmd p" | endif')

def executeSync(cmd):
    command(':cexpr system("{}")'.format(cmd))

# ----------
# JSON UTILS
# ----------

def loadJsonData(json_path):
    if not os.path.isfile(json_path):
        #print('Not found file: {}'.format(json_path))
        return None
    try:
        with open(json_path) as f:
            return json.load(f)
    except IOError as err:
        eprint('File IO Error: {}'.format(err))
    except json.decoder.JSONDecodeError as err:
        eprint('JSON Decode Error: {}'.format(err))
    except:
        eprint('Unknown JOSN Error')
    return None

def saveJsonData(json_path, json_data, indent=4):
    with open(json_path, 'w') as f:
        f.write(json.dumps(json_data, indent=indent))
        return True
    return False

# ----------
# DEBUG TYPE
# ----------

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


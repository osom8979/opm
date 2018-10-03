#!/usr/bin/env python
# -*- coding: utf-8 -*-

from .common import *
import os
import sys
import vim
import tempfile

SCRIPT_PATH = os.path.abspath(__file__)
SCRIPT_DIR = os.path.dirname(SCRIPT_PATH)
DEBUGGER_DIR = os.path.join(SCRIPT_DIR, 'debugger')
LLDB_SCRIPT_PATH = os.path.join(DEBUGGER_DIR, 'lldb_script.py')
GDB_SCRIPT_PATH = os.path.join(DEBUGGER_DIR, 'gdb_script.py')

class DebuggingError(Exception):
    """
    Base class for exceptions in this module.
    """

    message = str()

    def __init__(self, message):
        self.message = message

class ParseError(DebuggingError):

    def __init__(self, expression):
        super.__init__('Parse error: {}'.format(expression))

class EmptyStringError(DebuggingError):

    def __init__(self, expression):
        super.__init__('Empty string error: {}'.format(expression))


def getLLDBInitScript():
    script = str()
    script += 'command script import {}\n'.format(LLDB_SCRIPT_PATH)
    script += 'command script add -f lldb_script.init opvim-lldb-init\n'
    script += 'opvim-lldb-init --socket={}\n'.format(os.environ['NVIM_LISTEN_ADDRESS'])
    script += 'settings set stop-line-count-before 0\n'
    script += 'settings set stop-line-count-after 0\n'
    return script

def createInitScript(debug_type):
    temp_script_path = getDebuggingTempScriptPath()
    if temp_script_path:
        temp_script_file = open(temp_script_path, 'w')
    else:
        temp_script_file = tempfile.NamedTemporaryFile(delete=False)
        temp_script_path = temp_script_file.name

    # Save the temporary path in a cache variable.
    setCacheDebuggingTempScriptPath(temp_script_path)

    if debug_type == DEBUG_TYPE_GDB:
        pass
    elif debug_type == DEBUG_TYPE_LLDB:
        temp_script_content = getLLDBInitScript()
    elif debug_type == DEBUG_TYPE_PDB:
        pass
    else:
        raise 'Unknown debug type: {}'.format(debug_type)

    if not temp_script_content:
        raise 'Empty script content.'

    temp_script_file.write(temp_script_content.encode())
    return temp_script_path

def removeInitScript():
    temp_script_path = getCacheDebuggingTempScriptPath()
    if os.path.isfile(temp_script_path):
        os.remove(temp_script_path)
    setCacheDebuggingTempScriptPath('') # clear cache.

def newInitScript(debug_type):
    removeInitScript()
    return createInitScript(debug_type)

def getTerminalOption(cwd):
    return "{ 'cwd': '" + cwd + "', 'on_exit': 'opvim#OnDebuggerExit', 'rpc': v:true }"

class Debugging:
    """
    opm-vim debugging class.
    """

    debug_type = str()
    debug_cwd = str()
    debug_cmds = str()

    def __init__(self, debug_type, debug_cwd, debug_cmds):
        if not debug_type:
            raise EmptyStringError('type')
        if not debug_cwd:
            raise EmptyStringError('cwd')
        if not debug_cmds:
            raise EmptyStringError('cmds')

        self.debug_type = getCheckedDebugType(debug_type)
        if not self.debug_type:
            raise ParseError(debug_type)

        self.debug_cwd = debug_cwd
        self.debug_cmds = debug_cmds

    def run(self):
        height = getDebuggingWindowHeight()
        cwd = self.debug_cwd
        program = self.debug_type
        args = self.debug_cmds

        #for w in vim.windows:
        #    print('buffers: '.format(w.buffer.name))
        temp_script_path = newInitScript(program)

        if program == DEBUG_TYPE_GDB:
            full_cmd = 'gdb {}'.format(args)
        elif program == DEBUG_TYPE_LLDB:
            full_cmd = 'lldb -S {} {}'.format(temp_script_path, args)
        elif program == DEBUG_TYPE_PDB:
            full_cmd = ''
        else:
            raise 'Unknown debug type: {}'.format(program)

        full_options = getTerminalOption(cwd)

        if getDebuggingPreview():
            print('cmds: {}'.format(full_cmd))
            print('options: {}'.format(full_options))

        # create horizontal split to display the current file
        command('belowright {}new'.format(height))
        command('let g:opvim_cache_debugging_job_id = termopen("{}")'.format(full_cmd))
        command('startinsert')

def getDebugging(debug_type, debug_cwd, debug_cmds):
    return Debugging(debug_type, debug_cwd, debug_cmds)


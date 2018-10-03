#!/usr/bin/env python
# -*- coding: utf-8 -*-

from .common import *
import os
import sys
import vim
import tempfile
import sys

SCRIPT_PATH = os.path.abspath(__file__)
SCRIPT_DIR = os.path.dirname(SCRIPT_PATH)
DEBUGGER_DIR = os.path.join(SCRIPT_DIR, 'debugger')

FIFO_SERVER_PATH = os.path.join(DEBUGGER_DIR, 'fifo_server.py')
LLDB_SCRIPT_PATH = os.path.join(DEBUGGER_DIR, 'lldb_script.py')
GDB_SCRIPT_PATH = os.path.join(DEBUGGER_DIR, 'gdb_script.py')

# ----------
# Exceptions
# ----------

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

# ------------------
# Utility functions.
# ------------------

def getLLDBInitScript(fifo_path):
    script = str()
    script += 'command script import {}\n'.format(LLDB_SCRIPT_PATH)
    script += 'command script add -f lldb_script.init opvim-lldb-init\n'
    script += 'opvim-lldb-init --fifo={}\n'.format(fifo_path)
    script += 'settings set stop-line-count-before 0\n'
    script += 'settings set stop-line-count-after 0\n'
    return script

def createInitScript(debug_type, fifo_path):
    temp_script_file = tempfile.NamedTemporaryFile(delete=False)
    temp_script_path = temp_script_file.name

    # Save the temporary path in a cache variable.
    setCacheDebuggingTempScriptPath(temp_script_path)

    if debug_type == DEBUG_TYPE_GDB:
        pass
    elif debug_type == DEBUG_TYPE_LLDB:
        temp_script_content = getLLDBInitScript(fifo_path)
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

def newInitScript(debug_type, fifo_path):
    removeInitScript()
    return createInitScript(debug_type, fifo_path)

def createFifo():
    temp_dir = tempfile.mkdtemp()
    temp_fifo_path = os.path.join(temp_dir, 'opvim-fifo')

    # Save the temporary path in a cache variable.
    setCacheDebuggingTempFifoPath(temp_fifo_path)

    try:
        os.mkfifo(temp_fifo_path)
    except OSError as e:
        raise 'Failed to create FIFO: {}'.format(e)
    return temp_fifo_path

def removeFifo():
    temp_fifo_path = getCacheDebuggingTempFifoPath()
    if os.path.isfile(temp_fifo_path):
        os.remove(temp_fifo_path)
    os.rmdir(os.path.dirname(temp_fifo_path))
    setCacheDebuggingTempFifoPath('') # clear cache.

def newFifo():
    removeFifo()
    return createFifo()

def getCommands(debug_type, debugger_script_path, user_args):
    if debug_type == DEBUG_TYPE_GDB:
        return 'gdb {}'.format(user_args)
    elif debug_type == DEBUG_TYPE_LLDB:
        return 'lldb -S {} {}'.format(debugger_script_path, user_args)
    elif debug_type == DEBUG_TYPE_PDB:
        return ''
    else:
        raise 'Unknown debug type: {}'.format(debug_type)

def getTerminalOption(on_exit, cwd=str()):
    if cwd:
        return "{'cwd':'" + cwd + "','on_exit':'" + on_exit + "'}"
    else:
        return "{'on_exit':'" + on_exit + "'}"

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
        args = self.debug_cmds

        temp_fifo_path = newFifo()
        temp_script_path = newInitScript(self.debug_type, temp_fifo_path)

        final_cmds = getCommands(self.debug_type, temp_script_path, args)
        final_opts = getTerminalOption('opvim#OnDebuggerExit', cwd)

        if getDebuggingPreview():
            print('cmds: {}'.format(final_cmds))
            print('options: {}'.format(final_opts))

        # Start background jobs.
        job_store = 'g:opvim_cache_debugging_fifo_server_job_id'
        fifo_cmds = '{} {}'.format(sys.executable, FIFO_SERVER_PATH)
        fifo_opts = getTerminalOption('opvim#OnDebuggerFifoExit')
        command('let {} = jobstart({}, {})'.format(job_store, fifo_cmds, fifo_opts))

        # Start Debugger
        command('belowright {}new'.format(height))
        command('termopen("{}", {})'.format(final_cmds, final_opts))
        command('startinsert')

# -----------------
# Publish interface
# -----------------

def startDebugging(debug_type, debug_cwd, debug_cmds):
    Debugging(debug_type, debug_cwd, debug_cmds).run()


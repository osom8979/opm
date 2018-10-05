#!/usr/bin/env python
# -*- coding: utf-8 -*-

from .common import *
import os
import sys
import tempfile
import optparse
import shlex
import vim

SCRIPT_PATH = os.path.abspath(__file__)
SCRIPT_DIR = os.path.dirname(SCRIPT_PATH)
DEBUGGER_DIR = os.path.join(SCRIPT_DIR, 'debugger')

FIFO_SERVER_PATH = os.path.join(DEBUGGER_DIR, 'fifo_server.py')
LLDB_SCRIPT_PATH = os.path.join(DEBUGGER_DIR, 'lldb_script.py')
GDB_SCRIPT_PATH = os.path.join(DEBUGGER_DIR, 'gdb_script.py')

GLOBAL_JOB_STORE_KEY = GLOBAL_KEY_DEBUGGING_FIFO_SERVER_ID

# ----------
# Exceptions
# ----------

class DebuggingError(Exception):
    message = str()
    def __init__(self, message):
        self.message = message

class ParseError(DebuggingError):
    def __init__(self, expression):
        super.__init__('Parse error: {}'.format(expression))

class EmptyStringError(DebuggingError):
    def __init__(self, expression):
        super.__init__('Empty string error: {}'.format(expression))

class NoDirError(DebuggingError):
    def __init__(self, expression):
        super.__init__('Not found directory: {}'.format(expression))

# ---------------
# Debugging class
# ---------------

class Debugging:
    """
    opm-vim debugging class.
    """

    debug_type = str()
    debug_cwd = str()
    debug_cmds = str()

    setting_dir = '.opvim'
    fifo_name = 'debugging.fifo'
    init_name = 'debugging-init.py'
    window_height = 10

    def __init__(self, debug_type, debug_cwd, debug_cmds, **kwargs):
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

        if 'setting_dir' in kwargs:
            self.setting_dir = kwargs['setting_dir']
        if 'fifo_name' in kwargs:
            self.fifo_name = kwargs['fifo_name']
        if 'init_name' in kwargs:
            self.init_name = kwargs['init_name']
        if 'window_height' in kwargs:
            self.window_height = kwargs['window_height']

        if not os.path.isdir(self.setting_dir):
            raise NoDirError(self.setting_dir)

    # ----------
    # File path.
    # ----------

    def getFifoPath(self):
        return os.path.join(self.setting_dir, self.fifo_name)

    def getInitPath(self):
        return os.path.join(self.setting_dir, self.init_name)

    # ----------
    # FIFO file.
    # ----------

    def createFifo(self):
        try:
            os.mkfifo(self.getFifoPath())
        except OSError as e:
            raise 'Failed to create FIFO: {}'.format(e)

    def removeFifo(self):
        if os.path.exists(self.getFifoPath()):
            os.remove(self.getFifoPath())

    def newFifo(self):
        self.removeFifo()
        self.createFifo()

    # -----------------------
    # Debugger's init script.
    # -----------------------

    def getLLDBInitScript(self):
        script = str()
        script += 'command script import {}\n'.format(LLDB_SCRIPT_PATH)
        script += 'command script add -f lldb_script.init opvim-lldb-init\n'
        script += 'opvim-lldb-init --fifo={}\n'.format(self.getFifoPath())
        script += 'settings set stop-line-count-before 0\n'
        script += 'settings set stop-line-count-after 0\n'
        return script

    def createInitScript(self):
        if self.debug_type == DEBUG_TYPE_GDB:
            pass
        elif self.debug_type == DEBUG_TYPE_LLDB:
            temp_script_content = self.getLLDBInitScript()
        elif self.debug_type == DEBUG_TYPE_PDB:
            pass

        if not temp_script_content:
            raise 'Empty script content.'

        with open(self.getInitPath(), 'w') as f:
            f.write(temp_script_content)

    def removeInitScript(self):
        if os.path.exists(self.getInitPath()):
            os.remove(self.getInitPath())

    def newInitScript(self):
        self.removeInitScript()
        self.createInitScript()

    # ----------------
    # Debugger command
    # ----------------

    def getDebuggerCommands(self):
        if self.debug_type == DEBUG_TYPE_GDB:
            return '"gdb {}"'.format(self.debug_cmds)
        elif self.debug_type == DEBUG_TYPE_LLDB:
            return '"lldb -S {} {}"'.format(self.getInitPath(), self.debug_cmds)
        elif self.debug_type == DEBUG_TYPE_PDB:
            return '""'

    def getDebuggerOptions(self):
        return "{'cwd':'" + self.debug_cwd + "','on_exit':'opvim#OnDebuggerExit'}"

    # -------------------
    # FIFO Server command
    # -------------------

    def getFifoServerCommandsList(self):
        return '["{}", "{}", "{}", "{}"]'.format(
                sys.executable,
                FIFO_SERVER_PATH,
                "--fifo=" + self.getFifoPath(),
                "--nvim=" + os.environ['NVIM_LISTEN_ADDRESS'])

    def getFifoServerOptions(self):
        return "{" \
               "'on_stdout':'opvim#OnDebuggerFifoStdout'," \
               "'on_stderr':'opvim#OnDebuggerFifoStderr'," \
               "'on_exit':'opvim#OnDebuggerFifoExit'"      \
               "}"

    # ------
    # Runner
    # ------

    def run(self):
        self.newFifo()
        self.newInitScript()

        final_cmds = self.getDebuggerCommands()
        final_opts = self.getDebuggerOptions()

        fifo_cmds = self.getFifoServerCommandsList()
        fifo_opts = self.getFifoServerOptions()

        if isDeveloperDebug():
            print('Debugger cmds: {}'.format(final_cmds))
            print('Debugger opts: {}'.format(final_opts))
            print('FIFO server cmds: {}'.format(fifo_cmds))
            print('FIFO server opts: {}'.format(fifo_opts))

        # Start background jobs.
        command('let g:{} = jobstart({}, {})'.format(GLOBAL_JOB_STORE_KEY, fifo_cmds, fifo_opts))

        if isDeveloperDebug():
            print('FIFO server: job ID: {}'.format(getGlobalVariable(GLOBAL_JOB_STORE_KEY)))

        # Start Debugger
        command('belowright {}new'.format(self.window_height))
        command('call termopen({}, {})'.format(final_cmds, final_opts))
        command('startinsert')


# -----------------
# Publish interface
# -----------------

def getDebugging(debug_type, debug_cwd, debug_cmds):
    return Debugging(debug_type, debug_cwd, debug_cmds,
                     setting_dir=getProjectSettingDir(),
                     fifo_name=getDebuggingFifoName(),
                     init_name=getDebuggingScriptName(),
                     window_height=getDebuggingWindowHeight())

def startDebugging(debug_type, debug_cwd, debug_cmds):
    getDebugging(debug_type, debug_cwd, debug_cmds).run()


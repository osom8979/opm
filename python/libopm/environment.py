# -*- coding: utf-8 -*-
"""! OPM Environment Variables.
@author zer0
@date   2015-12-17
"""

import os
import __main__ as main
from optparse import OptionParser

SCRIPT_PATH = os.path.abspath(main.__file__)
RUNTIME_DIR = os.path.dirname(SCRIPT_PATH)

OPM_HOME  = os.environ['OPM_HOME']
OPM_BIN   = os.path.join(OPM_HOME, 'bin')
OPM_INC   = os.path.join(OPM_HOME, 'include')
OPM_LIB   = os.path.join(OPM_HOME, 'lib')
OPM_TMP   = os.path.join(OPM_HOME, 'tmp')
OPM_CACHE = os.path.join(OPM_TMP,  'cache')

CONFIG_XML_NAME = 'config.xml'
CONFIG_XML_PATH = os.path.join(OPM_TMP, CONFIG_XML_NAME)

CMD_HELP   = 'help'
CMD_INFO   = 'info'
CMD_CONFIG = 'config'

CMD_MAP = {
    CMD_HELP:   'show this help message and exit.',
    CMD_INFO:   'show opm information.',
    CMD_CONFIG: 'create a config file.'
}

CMD_MESSAGE = "\nCommand list:\n"

for key, val in CMD_MAP.iteritems():
    CMD_MESSAGE += '{}\t{}\n'.format(key, val)



def printCommandHelp():
    print CMD_MESSAGE


def getEnvironmentPath():
    return SCRIPT_PATH


def parseArguments(argv, print_help=True):
    ENABLE_DEFAULT_HELP_MESSAGE = False
    command = None

    if len(argv) >= 2:
        arg1 = argv[1]
        for cursor in CMD_MAP.keys():
            if cursor == arg1:
                command = cursor
                argv.pop(1)
                break

    parser = OptionParser(add_help_option=ENABLE_DEFAULT_HELP_MESSAGE)
    parser.set_usage('Usage: opm {COMMAND} {OPTIONS}')
    parser.add_option('-c', '--config-path'
        , dest='config_path', metavar='PATH', default=CONFIG_XML_PATH
        , help='Set the configure file path.')
    options, args = parser.parse_args(argv)

    if print_help == True and (command == None or command == CMD_HELP):
        parser.print_help()
        printCommandHelp()

    return command, options


if __name__ == '__main__':
    print 'OPM_HOME: ' + OPM_HOME
    print 'SCRIPT: ' + getEnvironmentPath()

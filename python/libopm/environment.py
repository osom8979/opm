# -*- coding: utf-8 -*-
"""! OPM Environment Variables.
@author zer0
@date   2015-12-17
"""

import os
import __main__ as main

SCRIPT_PATH = os.path.abspath(main.__file__)
RUNTIME_DIR = os.path.dirname(SCRIPT_PATH)

OPM_HOME = os.environ['OPM_HOME']
OPM_BIN  = os.path.join(OPM_HOME, 'bin')
OPM_INC  = os.path.join(OPM_HOME, 'include')
OPM_LIB  = os.path.join(OPM_HOME, 'lib')

CONFIG_XML_NAME  = 'config.xml'


def getEnvironmentPath():
    return SCRIPT_PATH


if __name__ == '__main__':
    print 'OPM_HOME: ' + OPM_HOME
    print 'SCRIPT: ' + getEnvironmentPath()

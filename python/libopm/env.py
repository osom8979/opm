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

TAR_NAME  = 'tar'
GZIP_NAME = 'gz'
ARCHIVE_EXTENSION = '.{}.{}'.format(TAR_NAME, GZIP_NAME)

VERSION_MIN_MAJOR = 0
VERSION_MIN_MINOR = 1
VERSION_MIN = '{}.{}'.format(VERSION_MIN_MAJOR, VERSION_MIN_MINOR)

CONFIG_XML_NAME  = 'config.xml'
PKGINFO_XML_NAME = 'pkginfo.xml'


if __name__ == '__main__':
    pass

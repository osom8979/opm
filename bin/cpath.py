#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import re
from optparse import OptionParser
from subprocess import Popen, PIPE, STDOUT

GCC_CMD = 'g++ -std=c++11 -E -v -x c++ - < /dev/null'

OPTION_PARSER = OptionParser()
OPTION_PARSER.add_option('-f', '--files',
                         dest='files',
                         action='store_true',
                         default=False,
                         help='Print header files.')
(OPTIONS, ARGS) = OPTION_PARSER.parse_args()

def findChildren(directory):
    result = []
    for dirpath, dirnames, filenames in os.walk(directory):
        for filename in filenames:
            result += [os.path.join(dirpath, filename)]
    return result

def getStderrResult(command):
    popen = Popen(command,
                  shell=True,
                  stdin=PIPE,
                  stdout=PIPE,
                  stderr=STDOUT,
                  close_fds=True)
    return popen.stdout.read()

def getGccIncludeList(verbose):
    result = []
    enable = False
    for cursor in verbose.split('\n'):
        line = cursor.strip()
        if re.match(r'^End of search list\.$', line):
            enable = False
        elif re.match(r'^#include .*', line):
            enable = True
        elif enable:
            if not re.match(r'^\.$', line):
                result += [str(line)]
    return result

if __name__ == '__main__':
    dir_list = getGccIncludeList(getStderrResult(GCC_CMD))
    if OPTIONS.files:
        for cursor in dir_list:
            for file in findChildren(cursor):
                print file
    else:
        for cursor in dir_list:
            print cursor

# -*- coding: utf-8 -*-
"""! OPM File manager.
@author zer0
@date   2015-12-19
"""

import os
import re


def getChildDirectories(path):
    result = []
    for parent, unused_subdirs, files in os.walk(path):
        result += [parent]
    return result


def getChildren(path):
    result = []
    for parent, unused_subdirs, files in os.walk(path):
        for name in files:
            # result += [os.path.join(os.path.abspath(parent), name)]
            result += [os.path.join(parent, name)]
    return result


def getChildrenWithMatch(path, regexp):
    result = []
    for cursor in getChildren(path):
        if not re.match(regexp, cursor) is None:
            result += [cursor]
    return result


if __name__ == '__main__':
    pass

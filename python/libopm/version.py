# -*- coding: utf-8 -*-
"""! OPM Version information.
@author zer0
@date   2015-12-19
"""

VERSION_MIN_MAJOR = 0
VERSION_MIN_MINOR = 1
VERSION_SEPARATOR = '.'
VERSION_MIN = '{}{}{}'.format(VERSION_MIN_MAJOR,
                              VERSION_SEPARATOR,
                              VERSION_MIN_MINOR)


def version():
    return VERSION_MIN


def getMajorVersion(ver):
    return ver[:str(ver).find(VERSION_SEPARATOR)]


def getMinorVersion(ver):
    return ver[str(ver).find(VERSION_SEPARATOR)+1:]


if __name__ == '__main__':
    version = version()
    format_str = 'VERSION: MAJOR({}), MINOR({})'
    print format_str.format(getMajorVersion(version),
                            getMinorVersion(version))

# -*- coding: utf-8 -*-
"""! OPM entry-point.
@author zer0
@date   2015-12-19
"""

import sys

import archive     as ARCHIVE
import config      as CONFIG
import curl        as CURL
import environment as ENV
import version     as VERSION


def main():
    command, options = ENV.parseArguments(sys.argv)


if __name__ == '__main__':
    print ENV.parseArguments(sys.argv)

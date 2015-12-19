# -*- coding: utf-8 -*-
"""! OPM entry-point.
@author zer0
@date   2015-12-19
"""

import os
import sys

import archive     as ARCHIVE
import config      as CONFIG
import curl        as CURL
import environment as ENV
import version     as VERSION


def main_list(options):
    pass


def main_info(options):
    # CONFIG:
    print 'CONFIG PATH: ' + options.config_path
    if os.path.exists(options.config_path):
        config_map = CONFIG.readConfigXml(options.config_path)
        print '> VERSION: '   + config_map[CONFIG.ATTR_VERSION]
        print '> NAME: '      + config_map[CONFIG.ATTR_NAME]
        print '> PROTOCOL: '  + config_map[CONFIG.TAG_PROTOCOL]
        print '> USER: '      + config_map[CONFIG.TAG_USER]
        print '> HOST: '      + config_map[CONFIG.TAG_HOST]
        print '> PORT: '      + config_map[CONFIG.TAG_PORT]
        print '> PATH: '      + config_map[CONFIG.TAG_PATH]
    else:
        print '> Not found config file.'

    print 'OPM VERSION: ' + VERSION.version()


def main_config(options):
    config_path = options.config_path
    config_map  = CONFIG.getConfigMapWithInteractive()

    print 'Config path: ' + config_path
    try:
        CONFIG.writeConfigXmlWithMap(config_path, config_map)
        print 'Succeeded in configuration write.'
    except:
        print 'Failed in configuration write.'


# ------------
# ENTRY-POINT.
# ------------

def main():
    command, options = ENV.parseArguments(sys.argv)
    if command == None or command == ENV.CMD_HELP:
        return
    eval('main_{}(options)'.format(command))


if __name__ == '__main__':
    print ENV.parseArguments(sys.argv)

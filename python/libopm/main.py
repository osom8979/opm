# -*- coding: utf-8 -*-
"""! OPM entry-point.
@author zer0
@date   2015-12-19
"""

import os
import sys
import getpass

import archive     as ARCHIVE
import config      as CONFIG
import curl        as CURL
import environment as ENV
import version     as VERSION
import file        as FILE


def getPassword():
    return getpass.getpass('Password:')


def main_list(options):
    regexp = '.*' + ARCHIVE.ARCHIVE_EXTENSION.replace('.', r'\.')
    for cursor in FILE.getChildrenWithMatch(ENV.OPM_CACHE, regexp):
        cache_length     = len(ENV.OPM_CACHE)
        extension_length = len(ARCHIVE.ARCHIVE_EXTENSION)
        print cursor[cache_length+1:][:(-1)*extension_length]


def main_info(options):
    print 'OPM VERSION: ' + VERSION.version()
    print 'CONFIG PATH: ' + options.config_path
    print 'OPM CACHE: '   + ENV.OPM_CACHE

    if not os.path.exists(options.config_path):
        print '> Not found config file.'
        return

    config = CONFIG.Config()
    config.readConfigXml(options.config_path)

    print '> VERSION: '   + config.getVersion()
    print '> NAME: '      + config.getName()
    print '> PROTOCOL: '  + config.getProtocol()
    print '> USER: '      + config.getUser()
    print '> HOST: '      + config.getHost()
    print '> PORT: '      + config.getPort()
    print '> PATH: '      + config.getPath()
    print '> URI: '       + config.getUri()


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
    if command is None or command == ENV.CMD_HELP:
        return
    eval('main_{}(options)'.format(command))


if __name__ == '__main__':
    print ENV.parseArguments(sys.argv)

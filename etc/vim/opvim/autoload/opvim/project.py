#!/usr/bin/env python
# -*- coding: utf-8 -*-

from .common import *
import os
import sys
import json
import pprint

CMAKE_KEY = 'cmake'
DEBUG_KEY = 'debug'

class Project:
    """
    opm-vim project class.
    """

    json_path = ''
    json_data = ''
    prefix = 'build-'
    mode = 'debug'

    def __init__(self, json_path, **kwargs):
        self.json_path = json_path
        self.json_data = Project.getJsonData(json_path)

        if 'mode' in kwargs:
            self.mode = kwargs['mode']
        if 'prefix' in kwargs:
            self.prefix = kwargs['prefix']

    def __str__(self):
        return '{}:{}'.format(self.json_path, self.mode)

    @staticmethod
    def getJsonData(json_path):
        if not os.path.isfile(json_path):
            #print('Not found file: {}'.format(json_path))
            return None
        try:
            with open(json_path) as f:
                return json.load(f)
        except IOError as err:
            eprint('File IO Error: {}'.format(err))
        except json.decoder.JSONDecodeError as err:
            eprint('JSON Decode Error: {}'.format(err))
        except:
            eprint('Unknown JOSN Error')
        return None

    def exists(self):
        return self.json_data is not None

    def getRoot(self):
        return os.path.abspath(os.path.join(self.json_path, os.pardir))

    def getDictionary(self):
        return self.json_data

    def getModes(self):
        if self.exists() and CMAKE_KEY in self.json_data:
            return list(self.json_data[CMAKE_KEY].keys())
        return list()

    def getCMakeDictionary(self, mode):
        if self.exists() and mode in self.getModes():
            return self.json_data[CMAKE_KEY][mode]
        return dict()

    def getDefaultCMakeDirectory(self, mode):
        return self.prefix + mode

    def getCMakeDirectory(self, mode):
        mode_data = self.getCMakeDictionary(mode)
        if mode_data and 'dir' in mode_data:
            return mode_data['dir'].strip()
        return self.getDefaultCMakeDirectory(mode).strip()

    def getCurrentCMakeDirectory(self):
        return self.getCMakeDirectory(self.mode)

    def getDefaultCMakeBuildType(self, mode):
        lower_mode = mode.lower()
        if lower_mode == 'debug':
            return 'Debug'
        if lower_mode == 'release':
            return 'Release'
        if lower_mode == 'release':
            return 'RelWithDebInfo'
        if lower_mode == 'minsizerel':
            return 'MinSizeRel'
        return str()

    def getDefaultCMakeFlags(self, mode):
        result = str()
        result += ' -DCMAKE_EXPORT_COMPILE_COMMANDS=ON'
        result += ' -DCMAKE_BUILD_TYPE={}'.format(self.getDefaultCMakeBuildType(mode))
        return result

    def getCMakeFlags(self, mode):
        mode_data = self.getCMakeDictionary(mode)
        if mode_data and 'flags' in mode_data:
            return mode_data['flags'].strip()
        return self.getDefaultCMakeFlags(mode).strip()

    def getCurrentCMakeFlags(self):
        return self.getCMakeFlags(self.mode)

    def preview(self):
        print('Project root: {}'.format(self.getRoot()))
        print('OPM-VIM json: {}'.format(self.json_path))
        print('Current mode: {}'.format(self.mode))

        if not self.exists():
            print('-- Not found project --')
            return

        for mode in self.getModes():
            mode_data = self.getCMakeDictionary(mode)
            print('[{}]:'.format(mode))
            print(' - dir: {}'.format(self.getCMakeDirectory(mode)))
            print(' - flags: {}'.format(self.getCMakeFlags(mode)))

        #pprint.pprint(self.json_data)
        pass


def getGlobalProject():
    return Project(getDefaultProjectJsonPath(),
                   mode=getProjectMode(),
                   prefix=getDefaultBuildPrefix())

def getFirstMode():
    modes = getGlobalProject().getModes()
    if modes:
        return modes[0]
    else:
        return None

def previewGlobalProject():
    getGlobalProject().preview()


#!/usr/bin/env python
# -*- coding: utf-8 -*-

from .common import *
import os
import sys
import json
import pprint

CMAKE_KEY = 'cmake'
GENERATOR_KEY = 'generator'

class Project:
    """
    opm-vim project class.
    """

    json_path = ''
    json_data = ''
    mode = ''

    def __init__(self, json_path, **kwargs):
        self.json_path = json_path
        self.json_data = Project.getJsonData(json_path)

        if 'mode' in kwargs:
            self.mode = kwargs['mode']

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

    def getGenerator(self):
        if self.exists() and GENERATOR_KEY in self.json_data:
            return self.json_data[GENERATOR_KEY]
        return str()

    def preview(self):
        print('Project root: {}'.format(self.getRoot()))
        print('OPM-VIM json: {}'.format(self.json_path))
        print('Current mode: {}'.format(self.mode))

        if not self.exists():
            print('-- Not found project --')
            return

        print('Generator: {}'.format(self.getGenerator()))
        print('Mode list: {}'.format(self.getModes()))
        pprint.pprint(self.json_data)

def getGlobalProject():
    return Project(getDefaultProjectJsonPath(),
                   mode=getProjectMode())

def getFirstMode():
    modes = getGlobalProject().getModes()
    if modes:
        return modes[0]
    else:
        return None

def previewGlobalProject():
    getGlobalProject().preview()


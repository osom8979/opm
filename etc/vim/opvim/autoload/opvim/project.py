#!/usr/bin/env python
# -*- coding: utf-8 -*-

from .common import *
import os
import json
import pprint

class Project:
    """
    opm-vim project class.
    """

    json_path = ''
    json_data = ''
    mode = ''

    def __init__(self, json_path, mode):
        self.json_path = json_path
        self.json_data = Project.getJsonData(json_path)
        self.mode = mode

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
            #print('File IO Error: {}'.format(err))
            pass
        return None

    def getRoot(self):
        return os.path.abspath(os.path.join(self.json_path, os.pardir))

    def preview(self):
        print('Project root: {}'.format(self.getRoot()))
        print('OPM-VIM json: {}'.format(self.json_path))
        print('Current mode: {}'.format(self.mode))
        if self.json_data is not None:
            pprint.pprint(self.json_data)
        else:
            print('-- Not found project --')

    def getDictionary(self):
        return self.json_data

def getGlobalProject():
    return Project(getDefaultProjectJsonPath(), getProjectMode())

def getFirstMode():
    # try:
    #     dic = getGlobalProject().getDictionary()
    #     if 'cmake' in dic:
    #         return ['cmake'][0]
    #     else:
    # except:
    return None

def previewGlobalProject():
    getGlobalProject().preview()


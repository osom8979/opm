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
        except IOError:
            #print('File IO Error: {}'.format(json_path))
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

def getGlobalProject():
    return Project(getDefaultProjectJsonPath(), getProjectMode())

def previewGlobalProject():
    getGlobalProject().preview()


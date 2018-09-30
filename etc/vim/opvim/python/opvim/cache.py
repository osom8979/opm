#!/usr/bin/env python
# -*- coding: utf-8 -*-

from .common import *

MODE_KEY = 'mode'

class Cache:
    """
    opm-vim cache class.
    """

    json_path = ''
    json_data = ''
    json_indent = 4
    mode = 'debug'

    def __init__(self, json_path):
        self.json_path = json_path
        self.json_data = loadJsonData(json_path)

    def __str__(self):
        return '{}:{}'.format(self.json_path, self.mode)

    def exists(self):
        """ Exists json dictionary? """
        return self.json_data is not None

    def save(self):
        """ Save json file. """
        saveJsonData(self.json_path, self.json_data, self.json_indent)

    ## -----------------------
    ## JSON First Depth Nodes.
    ## -----------------------

    def getMode(self):
        if self.exists() and MODE_KEY in self.json_data:
            return self.json_data[MODE_KEY]
        return str()

    def setMode(self, mode):
        if self.exists():
            json_data[MODE_KEY] = mode
            return True
        return False


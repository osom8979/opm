#!/usr/bin/env python
# -*- coding: utf-8 -*-

from .common import *
import os

MODE_KEY = 'mode'

class Cache:
    """
    opm-vim cache class.
    """

    json_path = str()
    json_data = dict()
    json_indent = 4

    def __init__(self, json_path, **kwargs):
        auto_create = True
        if 'auto_create' in kwargs:
            auto_create = kwargs['auto_create']
        self.json_path = json_path
        if not os.path.isfile(json_path) and auto_create:
            self.save()
        self.json_data = loadJsonData(json_path)

    def exists(self):
        """ Exists json dictionary? """
        return self.json_data is not None

    def save(self):
        """ Save json file. """
        return saveJsonData(self.json_path, self.json_data, self.json_indent)

    ## -----------------------
    ## JSON First Depth Nodes.
    ## -----------------------

    def getMode(self):
        if self.exists() and MODE_KEY in self.json_data:
            return self.json_data[MODE_KEY]
        return str()

    def setMode(self, mode):
        if self.exists():
            self.json_data[MODE_KEY] = mode
            return True
        return False


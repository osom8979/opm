# -*- coding: utf-8 -*-

from collections.abc import Mapping


class FrozenDict(Mapping):
    def __init__(self, *args, **kwargs):
        self._dict = dict(*args, **kwargs)

    def __iter__(self):
        return self._dict.__iter__()

    def __len__(self):
        return self._dict.__len__()

    def __getitem__(self, item):
        return self._dict.__getitem__(item)

    def __contains__(self, item):
        return self._dict.__contains__(item)

    def __eq__(self, other):
        return self._dict.__eq__(other)

    def __ne__(self, other):
        return self._dict.__ne__(other)

    def keys(self):
        return self._dict.keys()

    def values(self):
        return self._dict.values()

    def items(self):
        return self._dict.items()

    def get(self, key):
        return self._dict.get(key)

"""! Test OPM Archive library.
@author zer0
@date   2015-12-16
"""
# -*- coding: utf-8 -*-

import unittest
import os
import __main__ as main
import libopm.archive as Archive

ARCHIVE_NAME = 'test_archive'
CURRENT_SCRIPT = os.path.basename(main.__file__)


class TestArchive(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        Archive.compressArchive(ARCHIVE_NAME, [CURRENT_SCRIPT])

    @classmethod
    def tearDownClass(cls):
        if os.path.exists(ARCHIVE_NAME):
            os.remove(ARCHIVE_NAME)

    def testDefault(self):
        self.assertTrue(os.path.exists(ARCHIVE_NAME))

    def testReadFileListWithArchive(self):
        filelist = Archive.readFileListWithArchive(ARCHIVE_NAME)
        self.assertEquals(len(filelist), 1)
        self.assertEquals(filelist[0].name, CURRENT_SCRIPT)

    def testReadStringWithArchive(self):
        content = Archive.readStringWithArchive(ARCHIVE_NAME,
                                                CURRENT_SCRIPT)
        self.assertGreater(len(content), 1)
        self.assertTrue(content.find(ARCHIVE_NAME))

if __name__ == '__main__':
    unittest.main()

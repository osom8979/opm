"""! OPM Archive library.
@author zer0
@date   2015-12-16
"""
# -*- coding: utf-8 -*-

import tarfile

ARCHIVE_TYPE = 'gz'

READ_ARCHIVE_TYPE  = 'r:' + ARCHIVE_TYPE
WRITE_ARCHIVE_TYPE = 'w:' + ARCHIVE_TYPE


class ArchiveInfo(object):
    """! Single node information with archive.
    @author zer0
    @date   2015-12-06
    """

    def __init__(self, file_name, file_type, file_size):
        self.name = file_name
        self.type = file_type
        self.size = file_size

    def __str__(self):
        return '[{}] {} ({}byte)'.format(self.type, self.name, self.size)

    def __repr__(self):
        return self.name

    def isFile(self):
        return self.type in tarfile.REGULAR_TYPES

    def isDirectory(self):
        return self.type == tarfile.DIRTYPE


def readFileListWithArchive(path):
    """! Read archive file list.
    @param path [in] archive file path.
    @return If successful, it returns a ArchiveInfo array.
    """
    result = []
    with tarfile.open(path, READ_ARCHIVE_TYPE) as tar:
        for tarinfo in tar:
            result += [ArchiveInfo(tarinfo.name, tarinfo.type, tarinfo.size)]
    return result


def readStringWithArchive(path, name):
    """! Read a single file in the archive file.
    @param path [in] archive file path.
    @param name [in] Read filename.
    @return If successful, it returns string.
    """
    with tarfile.open(path, READ_ARCHIVE_TYPE) as tar:
        for tarinfo in tar:
            if tarinfo.name == name:
                return tar.extractfile(tarinfo.name).read()
    return None


def compressArchive(tar_gz_path, file_name_list, process_lamda=None):
    with tarfile.open(tar_gz_path, WRITE_ARCHIVE_TYPE) as tar:
        for file_name in file_name_list:
            if process_lamda:
                process_lamda(file_name)
            tar.add(file_name)


def extractArchive(tar_gz_path, extract_path, process_lamda=None):

    def yield_files(members):
        for tarinfo in members:
            if process_lamda:
                process_lamda(tarinfo.name)
            yield tarinfo

    with tarfile.open(tar_gz_path, READ_ARCHIVE_TYPE) as tar:
        tar.extractall(extract_path, members=yield_files(tar))


if __name__ == '__main__':
    pass

# -*- coding: utf-8 -*-
"""! OPM cURL wrapper.
@author zer0
@date   2015-12-17
@deprecated
"""

import os
import re
import subprocess

CURL_COMMAND  = 'curl'
CURL_INSECURE = '--insecure'
CURL_SILENT   = '--silent'
CURL_LIST     = '--list-only'
CURL_USER     = '--user'
CURL_UPLOAD   = '--upload-file'
CURL_OUTPUT   = '--output'
CURL_QUOTE    = '--quote'

SELF_DIR_NAME   = '.'
PARENT_DIR_NAME = '..'


def which(program):
    path = os.getenv('PATH')
    for cursor in path.split(os.path.pathsep):
        cursor = os.path.join(cursor, program)
        if os.path.exists(cursor) and os.access(cursor, os.X_OK):
            return cursor
    return None


def whichCurl():
    if which(CURL_COMMAND):
        return True
    else:
        return False


def isSelfOrParentDirectory(name):
    if name == SELF_DIR_NAME or name == PARENT_DIR_NAME:
        return True
    else:
        return False


def getUserPasswdForCurlFormat(user, passwd=None):
    if passwd:
        return '{}:{}'.format(user, passwd)
    else:
        return user


def runSubprocess(command):
    """! Run subprocess.
    @return standard output.
    """
    try:
        return 0, subprocess.check_output(command, shell=True)
    except subprocess.CalledProcessError as e:
        return e.returncode, e.output


def getUriPath(prefix, suffix=''):
    if prefix[len(prefix) - 1] == '/':
        return prefix + suffix
    else:
        return prefix + '/' + suffix


# ------------------
# Remote controller.
# ------------------

class FileInfo:
    """! Information of <code>ls -l</code> command result.
    @author zer0
    @date   2015-15-05
    """

    def __init__(self, string=None):
        self.split = re.split('[\s]+', string)

    def getPermission(self):
        return self.split[0]
    def getHardlink(self):
        return self.split[1]
    def getUser(self):
        return self.split[2]
    def getGroup(self):
        return self.split[3]
    def getSize(self):
        return self.split[4]
    def getMonth(self):
        return self.split[5]
    def getDay(self):
        return self.split[6]
    def getTimeOrYear(self):
        return self.split[7]
    def getName(self):
        return self.split[8]

    def isDirectory(self):
        if self.getPermission()[0] == 'd':
            return True
        else:
            return False


def uploadFile(remote_uri, file_path, user, passwd, print_output=False):
    command  = [CURL_COMMAND, CURL_INSECURE]
    command += [CURL_USER, getUserPasswdForCurlFormat(user, passwd)]
    command += [CURL_UPLOAD, file_path]
    command += [remote_uri]
    result_code, output = runSubprocess(command)

    if result_code != 0 and print_output:
        print output

    return result_code


def downloadFile(remote_uri, file_path, user, passwd, print_output=False):
    command  = [CURL_COMMAND, CURL_INSECURE]
    command += [CURL_USER, getUserPasswdForCurlFormat(user, passwd)]
    command += [remote_uri]
    command += [CURL_OUTPUT, file_path]
    result_code, output = runSubprocess(command)

    if result_code != 0 and print_output:
        print output

    return result_code


def downloadFileList(remote_uri, user, passwd, print_output=False):
    command  = [CURL_COMMAND, CURL_INSECURE, CURL_SILENT]
    command += [CURL_USER, getUserPasswdForCurlFormat(user, passwd)]
    command += [getUriPath(remote_uri)]
    result_code, output = runSubprocess(command)

    if result_code != 0:
        if print_output:
            print 'cURL error ({})'.format(result_code)
        return result_code, []

    file_list = []
    for cursor in output.strip().split('\n'):
        file_info = FileInfo(cursor)
        if not isSelfOrParentDirectory(file_info.getName()):
            file_list += [file_info]
    return 0, file_list


if __name__ == '__main__':
    pass

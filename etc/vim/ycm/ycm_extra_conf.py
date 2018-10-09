#!/usr/bin/env python

import os
import platform
import json
import __main__ as main
import ycm_core

SCRIPT_PATH = os.path.abspath(main.__file__)
SCRIPT_DIR = os.path.dirname(SCRIPT_PATH)
WORKING_DIR = os.getcwd()

ENABLE_WRITE_LOG = True
WRITE_INFO_FILE = 'ycm_extra_conf.log'

CUDA_LOWER_EXTENSIONS = ['.cu']
CUDA_UPPER_EXTENSIONS = ['.CU']

CUDA_HEADER_LOWER_EXTENSIONS = ['.cuh']
CUDA_HEADER_UPPER_EXTENSIONS = ['.CUH']

OBJC_LOWER_EXTENSIONS = ['.m', '.mm']
OBJC_UPPER_EXTENSIONS = ['.M', '.MM']

C_LOWER_EXTENSIONS = ['.c']
C_UPPER_EXTENSIONS = ['.C']

CPP_LOWER_EXTENSIONS = ['.c++', '.cc', '.cp', '.cpp', '.cxx']
CPP_UPPER_EXTENSIONS = ['.C++', '.CC', '.CP', '.CPP', '.CXX']

CPP_HEADER_LOWER_EXTENSIONS = ['.h', '.h++', '.hh', '.hp', '.hpp', '.hxx', '.inl', '.pch']

SOURCE_EXTENSIONS = list()
SOURCE_EXTENSIONS.extend(CUDA_LOWER_EXTENSIONS)
SOURCE_EXTENSIONS.extend(CUDA_UPPER_EXTENSIONS)
SOURCE_EXTENSIONS.extend(OBJC_LOWER_EXTENSIONS)
SOURCE_EXTENSIONS.extend(OBJC_UPPER_EXTENSIONS)
SOURCE_EXTENSIONS.extend(C_LOWER_EXTENSIONS)
SOURCE_EXTENSIONS.extend(C_UPPER_EXTENSIONS)
SOURCE_EXTENSIONS.extend(CPP_LOWER_EXTENSIONS)
SOURCE_EXTENSIONS.extend(CPP_UPPER_EXTENSIONS)

HEADER_LOWER_EXTENSIONS = list()
HEADER_LOWER_EXTENSIONS.extend(CUDA_HEADER_LOWER_EXTENSIONS)
HEADER_LOWER_EXTENSIONS.extend(CPP_HEADER_LOWER_EXTENSIONS)

def getExtensionLower(filename):
    return os.path.splitext(filename)[1].lower()

def isHeaderExtension(extension):
    return extension in HEADER_LOWER_EXTENSIONS

def isCudaExtension(extension):
    return extension in CUDA_LOWER_EXTENSIONS or extension in CUDA_HEADER_LOWER_EXTENSIONS

def isCExtension(extension):
    return extension in C_LOWER_EXTENSIONS

def isObjectiveCExtension(extension):
    return extension in OBJC_LOWER_EXTENSIONS

# Check opvim project.
OPVIM_JSON_NAME = 'opvim.json'
SETTING_DIR_NAME = '.opvim'
OPVIM_JSON_PATH = os.path.join(WORKING_DIR, OPVIM_JSON_NAME)
OPVIM_CACHE_NAME = 'opvim.cache.json'
OPVIM_CACHE_PATH = os.path.join(WORKING_DIR, SETTING_DIR_NAME, OPVIM_CACHE_NAME)

def loadJsonData(json_path):
    if not os.path.isfile(json_path):
        return None
    try:
        with open(json_path) as f:
            return json.load(f)
    except:
        pass
    return None

def getCurrentMode(cache_path):
    mode_key = 'mode'
    cache_json = loadJsonData(cache_path)
    if cache_json and mode_key in cache_json:
        return cache_json[mode_key]
    return str()

def getCMakeWorkingDirectory(opvim_path, mode):
    cmake_key = 'cmake'
    dir_key = 'dir'
    proj_json = loadJsonData(opvim_path)
    if not proj_json:
        return str()
    if not cmake_key in proj_json:
        return str()
    if not mode in proj_json[cmake_key]:
        return str()
    if not dir_key in proj_json[cmake_key][mode]:
        return str()
    return proj_json[cmake_key][mode][dir_key]

def getCurrentCMakeDirectory(opvim_path, cache_path):
    default_prefix = 'build-'
    mode = getCurrentMode(cache_path)
    if not mode:
        return str()
    cmake_dir = getCMakeWorkingDirectory(opvim_path, mode)
    if cmake_dir:
        return cmake_dir
    return default_prefix + mode

CURRNET_CMAKE_BUILD_DIR = getCurrentCMakeDirectory(OPVIM_JSON_PATH, OPVIM_CACHE_PATH)

# Set this to the absolute path to the folder (NOT the file!) containing the
# compile_commands.json file to use that instead of 'flags'. See here for
# more details: http://clang.llvm.org/docs/JSONCompilationDatabase.html
#
# You can get CMake to generate this file for you by adding:
#   set (CMAKE_EXPORT_COMPILE_COMMANDS ON)
# to your CMakeLists.txt file.
#
# Most projects will NOT need to set this to anything; you can just change the
# 'flags' list of compilation flags. Notice that YCM itself uses that approach.
COMPILATION_DATABASE_DIR = CURRNET_CMAKE_BUILD_DIR
COMPILATION_DATABASE_NAME = 'compile_commands.json'
COMPILATION_DATABASE_PATH = os.path.join(COMPILATION_DATABASE_DIR, COMPILATION_DATABASE_NAME)
if os.path.isfile(COMPILATION_DATABASE_PATH):
    COMPILATION_DATABASE = ycm_core.CompilationDatabase(COMPILATION_DATABASE_DIR)
else:
    COMPILATION_DATABASE = None

DEFAULT_FLAGS = [
         '-Wall',
         '-Wextra',
         '-Werror',
         '-Wno-long-long',
         '-Wno-variadic-macros',
         '-fexceptions',
         #'-DNDEBUG',
         '-isystem', '/usr/include',
         '-isystem', '/usr/local/include',
         '-I.',
         '-I./include',
         '-I./src']
if platform.system() != 'Windows':
    DEFAULT_FLAGS.append('-std=c++14')

def updateLanguageTypeFromExtension(filename):
    extension = getExtensionLower(filename)
    DEFAULT_FLAGS.append('-x')
    if isCudaExtension(extension):
        DEFAULT_FLAGS.append('cuda')
    elif isCExtension(extension):
        DEFAULT_FLAGS.append('c')
    elif isObjectiveCExtension(extension):
        DEFAULT_FLAGS.append('objc')
    else:
        DEFAULT_FLAGS.append('c++')

# a boolean indicating whether or not the result of this call (i.e. the list of flags) should be cached for this file name.
# Defaults to True. If unsure, the default is almost always correct.
DO_CACHE = True

# a boolean indicating that the flags should be used. Defaults to True. If unsure, the default is almost always correct.
FLAGS_READY = True


def writeLog(message, enable=ENABLE_WRITE_LOG):
    if enable and WRITE_INFO_FILE:
        with open(WRITE_INFO_FILE, 'a') as f:
            f.write(message)

def getCompilationInfoForFile(filename, database):
    """
    The compilation_commands.json file generated by CMake does not have entries
    for header files. So we do our best by asking the db for flags for a
    corresponding source file, if any. If one exists, the flags for that file
    should be good enough.
    """
    extension = getExtensionLower(filename)
    if isHeaderExtension(extension):
        basename = os.path.splitext(filename)[0]
        for extension in SOURCE_EXTENSIONS:
            replacement_source_file = basename + extension
            if os.path.exists(replacement_source_file):
                compilation_info = database.GetCompilationInfoForFile(replacement_source_file)
                # Bear in mind that compilation_info.compiler_flags_ does NOT return a python list,
                # but a "list-like" StringVec object
                if compilation_info.compiler_flags_:
                    return compilation_info
        return None
    return database.GetCompilationInfoForFile(filename)

def Settings(**kwargs):
    if not 'filename' in kwargs:
        return dict()
    filename = kwargs['filename']
    language = kwargs['language'] # cfamily, python
    client_data = kwargs['client_data'] # client_data['v:version']

    updateLanguageTypeFromExtension(filename)

    use_database = False
    final_flags = DEFAULT_FLAGS
    final_cwd = WORKING_DIR

    if COMPILATION_DATABASE:
        compilation_info = getCompilationInfoForFile(filename, COMPILATION_DATABASE)
        if compilation_info:
            use_database = True
            final_flags = list(compilation_info.compiler_flags_)
            final_cwd = str(compilation_info.compiler_working_dir_)

    writeLog('Database: {}\nFilename: {}\nFlags: {}\nWorking: {}\n\n'.format(
             use_database, filename, final_flags, final_cwd))

    return {'flags': final_flags,
            'include_paths_relative_to_dir': final_cwd,
            'override_filename': filename,
            'do_cache': DO_CACHE,
            'flags_ready': FLAGS_READY}

if __name__ == '__main__':
    pass


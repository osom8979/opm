#!/usr/bin/env python

import os
import platform
import __main__ as main
import ycm_core

SCRIPT_PATH = os.path.abspath(main.__file__)
SCRIPT_DIR = os.path.dirname(SCRIPT_PATH)
WORKING_DIR = os.getcwd()

ENABLE_WRITE_LOG = True
WRITE_INFO_FILE = 'ycm_extra_conf.log'

CUDA_LOWER_EXTENSIONS = ['.cu']
CUDA_UPPER_EXTENSIONS = ['.CU']

OBJC_LOWER_EXTENSIONS = ['.m', '.mm']
OBJC_UPPER_EXTENSIONS = ['.M', '.MM']

CPP_LOWER_EXTENSIONS = ['.c', '.c++', '.cc', '.cp', '.cpp', '.cxx']
CPP_UPPER_EXTENSIONS = ['.C', '.C++', '.CC', '.CP', '.CPP', '.CXX']

HEADER_LOWER_EXTENSIONS = ['.h', '.h++', '.hh', '.hp', '.hpp', '.hxx', '.cuh', '.inl', '.pch']

SOURCE_EXTENSIONS = list()
SOURCE_EXTENSIONS.append(CUDA_LOWER_EXTENSIONS)
SOURCE_EXTENSIONS.append(CUDA_UPPER_EXTENSIONS)
SOURCE_EXTENSIONS.append(OBJC_LOWER_EXTENSIONS)
SOURCE_EXTENSIONS.append(OBJC_UPPER_EXTENSIONS)
SOURCE_EXTENSIONS.append(CPP_LOWER_EXTENSIONS)
SOURCE_EXTENSIONS.append(CPP_UPPER_EXTENSIONS)

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
COMPILATION_DATABASE_DIR = WORKING_DIR
COMPILATION_DATABASE_NAME = 'compile_commands.json'
COMPILATION_DATABASE_PATH = os.path.join(COMPILATION_DATABASE_DIR, COMPILATION_DATABASE_NAME)

# OPVIM SETTINGS.
OPVIM_JSON = 'opvim.json'
OPVIM_PATH = os.path.join(WORKING_DIR, OPVIM_JSON)

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
         '-x', 'c++',
         '-isystem', '/usr/include',
         '-isystem', '/usr/local/include',
         '-I.',
         '-I./include',
         '-I./src']

if platform.system() != 'Windows':
    DEFAULT_FLAGS.append('-std=c++14')

# a boolean indicating whether or not the result of this call (i.e. the list of flags) should be cached for this file name.
# Defaults to True. If unsure, the default is almost always correct.
DO_CACHE = True

# a boolean indicating that the flags should be used. Defaults to True. If unsure, the default is almost always correct.
FLAGS_READY = True


def isHeaderFile(filename):
    return os.path.splitext(filename)[1].lower() in HEADER_LOWER_EXTENSIONS

def getCompilationInfoForFile(filename, database):
    """
    The compilation_commands.json file generated by CMake does not have entries
    for header files. So we do our best by asking the db for flags for a
    corresponding source file, if any. If one exists, the flags for that file
    should be good enough.
    """
    if isHeaderFile(filename):
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
    filename = kwargs['filename']
    language = kwargs['language'] # cfamily, python
    client_data = kwargs['client_data'] # client_data['v:version']

    final_flags = DEFAULT_FLAGS
    final_cwd = WORKING_DIR

    if COMPILATION_DATABASE:
        compilation_info = getCompilationInfoForFile(filename, COMPILATION_DATABASE)
        if compilation_info:
            final_flags = list(compilation_info.compiler_flags_)
            final_cwd = str(compilation_info.compiler_working_dir_)

    if ENABLE_WRITE_LOG and WRITE_INFO_FILE:
        with open(WRITE_INFO_FILE, 'a') as f:
            f.write('Filename: {}\n'.format(filename))
            f.write('Flags: {}\n'.format(final_flags))
            f.write('Working: {}\n'.format(final_cwd))
            f.write('\n')

    return {'flags': final_flags,
            'include_paths_relative_to_dir': final_cwd,
            'override_filename': filename,
            'do_cache': DO_CACHE,
            'flags_ready': FLAGS_READY}

if __name__ == '__main__':
    pass


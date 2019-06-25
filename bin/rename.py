import os
import re

def getChildren(path):
    result = []
    for parent, unused_subdirs, files in os.walk(path):
        for name in files:
            # result += [os.path.join(os.path.abspath(parent), name)]
            result += [os.path.join(parent, name)]
    return result

WORKING = os.getcwd()
TEST_MODE = True

for original_path in getChildren(WORKING):
    try:
        change_path = str(re.match(r'^.*[0-9][0-9]', original_path).group()).strip() + '.txt'
        print('Change: {}'.format(change_path))
        if not TEST_MODE:
            os.rename(original_path, change_path)
    except:
        print('Skip: {}'.format(original_path))


import os
import sys
import re
import subprocess

def execute(cmd) :
    fd = subprocess.Popen(cmd, shell=True,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE)
    return fd.stdout, fd.stderr

"""
Example output:
	linux-vdso.so.1 (0x00007ffd519c3000)
	libpthread.so.0 => /lib/x86_64-linux-gnu/libpthread.so.0 (0x00007f41fbf8f000)
	libdl.so.2 => /lib/x86_64-linux-gnu/libdl.so.2 (0x00007f41fbd8b000)
	librt.so.1 => /lib/x86_64-linux-gnu/librt.so.1 (0x00007f41fbb83000)
	libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007f41fb7e5000)
	libX11.so.6 => /usr/lib/x86_64-linux-gnu/libX11.so.6 (0x00007f41fb4ad000)
	libGL.so.1 => /usr/lib/x86_64-linux-gnu/libGL.so.1 (0x00007f41fb221000)
	libstdc++.so.6 => /usr/lib/x86_64-linux-gnu/libstdc++.so.6 (0x00007f41fae98000)
	libgcc_s.so.1 => /lib/x86_64-linux-gnu/libgcc_s.so.1 (0x00007f41fac80000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f41fa88f000)
	/lib64/ld-linux-x86-64.so.2 (0x00007f41fefe5000)
	libxcb.so.1 => /usr/lib/x86_64-linux-gnu/libxcb.so.1 (0x00007f41fa667000)
	libGLX.so.0 => /usr/lib/x86_64-linux-gnu/libGLX.so.0 (0x00007f41fa436000)
	libGLdispatch.so.0 => /usr/lib/x86_64-linux-gnu/libGLdispatch.so.0 (0x00007f41fa180000)
	libXau.so.6 => /usr/lib/x86_64-linux-gnu/libXau.so.6 (0x00007f41f9f7c000)
	libXdmcp.so.6 => /usr/lib/x86_64-linux-gnu/libXdmcp.so.6 (0x00007f41f9d76000)
	libbsd.so.0 => /lib/x86_64-linux-gnu/libbsd.so.0 (0x00007f41f9b61000)
"""
libraries, _ = execute('ldd ' + sys.argv[1])
dependencies = []

for line in libraries.readlines():
    cursor = line.decode(encoding='utf-8').strip()
    #print(cursor)

    try:
        address_start = re.search(r' \(0x[0-9a-f]*\)', cursor).start()
        names = cursor[:address_start].strip().split(' => ')
        find_file = names[-1]
        package_names_result, _ = execute('dpkg -S ' + find_file)
        package_name = package_names_result.read().decode(encoding='utf-8').strip()
        if package_name:
            print('Found:', package_name)
            """
            Example output:
            libc6:amd64: /lib/x86_64-linux-gnu/libpthread.so.0
            """
            dependencies.append(package_name.split(': ')[0])
        else:
            print('Not found:', find_file)
    except:
        print('Exception:', cursor)

deps = list(set(dependencies))
deps.sort()

if deps:
    dependencies_text = deps[0]
    for i in range(1, len(deps)):
        dependencies_text += ', ' + deps[i]

print('Dependencies:', dependencies_text)
print('Dependencies:', deps)


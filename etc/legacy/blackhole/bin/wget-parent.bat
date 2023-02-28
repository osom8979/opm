@echo off

CALL setup.bat

SET _WGET_EXE=%GNUWIN32_BIN%\wget.exe

IF NOT EXIST %_WGET_EXE% EXIT /B 2

%_WGET_EXE% -c -m -U -nc -np -r -k -l 0 %1

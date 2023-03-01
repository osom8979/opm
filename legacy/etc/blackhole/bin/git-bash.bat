@echo off

CALL setup.bat

SET GIT_SHELL=%GIT_BIN%\sh.exe

IF NOT EXIST %GIT_BIN% EXIT /B 2

%ComSpec% /c ""%GIT_SHELL%" --login -i"

@echo off

:: WARNING:
:: Use 'visual studio command prompt'

if "%1" == "" (
echo Usage: %0 {prefix}
exit /b 1
)
set "PREFIX=%1"

if not defined AM64 (
:: Default address-model: x86.
set AM64=0
)

if "%AM64%" == "0" (
set BJAM_ARCH_NAME=ntx86
set BOOST_ADDRESS_MODEL=32
) ELSE (
set BJAM_ARCH_NAME=ntx86_64
set BOOST_ADDRESS_MODEL=64
)

set BOOST_NAME=boost_1_60_0
set WORKING_DIR=%CD%

if not exist "%PREFIX%" (
mkdir "%PREFIX%"
)

cd %WORKING_DIR%\%BOOST_NAME%

set BJAM_PATH=%WORKING_DIR%\%BOOST_NAME%\tools\build\src\engine\bin.%BJAM_ARCH_NAME%\bjam.exe

if not exist "%BJAM_PATH%" (
echo not found bjam.exe
cd %WORKING_DIR%
exit /b 1
)

echo Build boost.
%BJAM_PATH% --prefix=%PREFIX% --layout=system toolset=gcc address-model=%BOOST_ADDRESS_MODEL% variant=release link=shared threading=multi install > build.boost.log

if "%ERRORLEVEL%" NEQ "0" (
echo SIGERR: %ERRORLEVEL%
) else (
echo Complete!
)

cd %WORKING_DIR%

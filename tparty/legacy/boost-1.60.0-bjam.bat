@echo off

:: WARNING:
:: Use 'visual studio command prompt'

set BOOST_NAME=boost_1_60_0
set WORKING_DIR=%CD%

tar xzf %BOOST_NAME%.tar.gz
cd %WORKING_DIR%\%BOOST_NAME%\tools\build\src\engine

echo Build bjam.
call build.bat gcc

cd %WORKING_DIR%

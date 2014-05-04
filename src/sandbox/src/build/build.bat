@echo off
setlocal EnableDelayedExpansion

set thisPath=%~dp0
set dtkRoot=%thisPath%\..\..\..
set bin_path=%thisPath%\..\..\bin
set srcDir=%dtkRoot%\src
cd %thisPath%\..

set import_libs=comctl32.lib ole32.lib uuid.lib

rem set versions=-version=DTK_LOG_EVAL
rem set versions=-version=DTK_LOG_EVENTS
rem set versions=-version=DTK_LOG_COM
rem set unittest=-unittest

if [%1]==[] goto :error
if [%2]==[] goto :error
goto :next

:error
echo Error: Must pass project name and source name as arguments.
goto :eof

:next

set FileName=%1
set SourceFile=%2

rdmd --compiler=dmd_msc.exe -w -g -L/SUBSYSTEM:WINDOWS:5.01 %versions% %unittest% -I%srcDir% %import_libs% -of%bin_path%\%FileName%.exe %SourceFile%

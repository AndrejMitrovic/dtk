@echo off
setlocal EnableDelayedExpansion

set thisPath=%~dp0
set dtkRoot=%thisPath%\..\..
set binPath=%dtkRoot%\bin
cd %thisPath%\..

set versions=-version=DTK_LOG_EVAL -version=DTK_LOG_EVENTS

if [%1]==[] goto :error
if [%2]==[] goto :error
goto :next

:error
echo Error: Must pass project name and source name as arguments.
goto :eof

:next

set FileName=%1
set SourceFile=%2

rdmd -w -g -L/SUBSYSTEM:WINDOWS:5.01 %versions% -unittest -I%dtkRoot%\src -of%binPath%\%FileName%.exe %SourceFile%

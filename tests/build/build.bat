@echo off
setlocal EnableDelayedExpansion

set thisPath=%~dp0
set dtkRoot=%thisPath%\..
set binPath=%dtkRoot%\bin
cd %thisPath%\..

if [%1]==[] goto :error
if [%2]==[] goto :error
goto :next

:error
echo Error: Must pass project name and source name as arguments.
goto :eof

:next

set FileName=%1
set SourceFile=%2

rdmd -g -version=DTK_LOG_EVAL -unittest -I..\src -of%binPath%\%FileName%.exe %SourceFile%

@echo off
setlocal EnableDelayedExpansion

set thisPath=%~dp0
set dtkRoot=%thisPath%\..\..\..
set binPath=%thisPath%\..\bin
cd %thisPath%\..

rem set versions=-version=DTK_LOG_EVAL
rem set versions=-version=DTK_LOG_EVENTS
rem set versions=-version=DTK_LOG_EVAL -version=DTK_LOG_EVENTS

set "static_lib_search=-L+C:\dev\projects\dtk\tests\cairo\bin\"
set "static_libs=libcairo-2.lib libgobject.lib libpango.lib libpangocairo.lib OpenGL32_implib.lib gdi32.lib"

set "versions=-version=CAIRO_HAS_PS_SURFACE -version=CAIRO_HAS_PDF_SURFACE -version=CAIRO_HAS_SVG_SURFACE -version=CAIRO_HAS_WIN32_SURFACE -version=CAIRO_HAS_PNG_FUNCTIONS -version=CAIRO_HAS_WIN32_FONT -version=WindowsAPI"

set includes=-IC:\dev\projects\cairoD\src -IC:\dev\projects\WindowsAPI

if [%1]==[] goto :error
if [%2]==[] goto :error
goto :next

:error
echo Error: Must pass project name and source name as arguments.
goto :eof

:next

set FileName=%1
set SourceFile=%2

rdmd -w -g -L/SUBSYSTEM:WINDOWS:5.01 %versions% %includes% %static_libs% %static_lib_search% -I%dtkRoot%\src -of%binPath%\%FileName%.exe %SourceFile%

@echo off
setlocal EnableDelayedExpansion

rem Build options
rem -------------
set build_tests=1
set run_tests=1

set thisPath=%~dp0
set designerRoot=%thisPath%\..
set buildPath=%thisPath%
set binPath=%designerRoot%\bin
cd %thisPath%\..\src

set dtkImport=%designerRoot%\..\..\src

set includes=-I%cd% -I%dtkImport%
set versions=
set import_libs=comctl32.lib ole32.lib uuid.lib
set flags=%includes% %versions% %import_libs% -g -unittest -w

set compiler=dmd.exe
rem set compiler=dmd_msc.exe
rem set compiler=ldmd2.exe

set main_file=designer\main.d
set exe_file=%binPath%\designer.exe

set cmd_build=rdmd --build-only -of%exe_file% -L/SUBSYSTEM:WINDOWS:5.01 --compiler=%compiler% %flags% %main_file%

set stdout_log=%buildPath%\designer_stdout.log
set stderr_log=%buildPath%\designer_stderr.log

echo. > %stdout_log%
echo. > %stderr_log%

:BUILD

%cmd_build%
if errorlevel 1 GOTO :ERROR

%exe_file%
if errorlevel 1 GOTO :ERROR

type %stdout_log%

goto :eof

:ERROR
type %stderr_log%
echo Failure: dtk designer tests failed.
goto :eof

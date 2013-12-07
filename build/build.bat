@echo off
setlocal EnableDelayedExpansion

rem Build options
rem -------------
set build_tests=1
rem set run_tests=1
rem set build_lib=1

set this_path=%~dp0
set dtk_root=%this_path%\..
set build_path=%this_path%
set bin_path=%dtk_root%\bin
set lib_path=%dtk_root%\lib
cd %this_path%\..\src

set "files="
for /r %%i in (*.d) do set files=!files! %%i

rem List of -version switches:
rem
rem DTK_UNITTEST
rem     - Enable unittests.
rem
rem DTK_LOG_EVAL
rem     - Logs Tcl eval commands.
rem
rem DTK_LOG_EVENT_HANDLER
rem     - Logs event handler calls.
rem
rem DTK_LOG_COM
rem     - Logs COM calls.
rem
rem DTK_LOG_TESTS
rem     - Logs log/logf calls, for use with unittesting.

set includes=-I%cd%
set debug_versions=-version=DTK_UNITTEST -version=DTK_LOG_TESTS
set import_libs=comctl32.lib ole32.lib uuid.lib
set flags=%includes% -g %debug_versions% %import_libs%

rem Set this to enforce building with unittests even for the static library.
rem Only use this during DTK development.
rem
set build_flags=-unittest

set compiler=dmd.exe
rem set compiler=dmd_msc.exe
rem set compiler=ldmd2.exe

set main_file=dtk\package.d
rem set main_file=dtk\all.d

set cmd_build_tests=rdmd --force --build-only -w -of%bin_path%\dtk_test.exe --main -L/SUBSYSTEM:WINDOWS:5.01 -unittest -g --compiler=%compiler% %flags% %main_file%

set stdout_log=%build_path%\dtktest_stdout.log
set stderr_log=%build_path%\dtktest_stderr.log

echo. > %stdout_log%
echo. > %stderr_log%

if [%build_tests%]==[] goto :BUILD

:TEST

timeit %cmd_build_tests%
if errorlevel 1 GOTO :ERROR
if [%run_tests%]==[] echo Success: dtk tests built.

if [%run_tests%]==[] goto :BUILD

%bin_path%\dtk_test.exe
if errorlevel 1 GOTO :ERROR

type %stdout_log%
echo Success: dtk tests passed.

:BUILD

if [%build_lib%]==[] goto :eof

%compiler% %build_flags% -g -of%bin_path%\dtk.lib -lib %flags% %files%
if errorlevel 1 GOTO :eof

echo Success: dtk built.
goto :eof

:ERROR
type %stderr_log%
echo Failure: dtk tests failed.
goto :eof

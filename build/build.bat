@echo off
setlocal EnableDelayedExpansion

set thisPath=%~dp0
set dtkRoot=%thisPath%\..
set buildPath=%thisPath%
set binPath=%dtkRoot%\bin
cd %thisPath%\..\src

set "files="
for /r %%i in (*.d) do set files=!files! %%i

rem List of -version switches:
rem
rem DTK_UNITTEST
rem     - Enable unittests.
rem
rem DTK_LOG_EVAL
rem     - Logs all Tcl eval commands.
rem
rem DTK_LOG_TESTS
rem     - Logs all log/logf calls, for use with unittesting.
rem

set includes=-I%cd%
rem set debug_versions=-version=DTK_LOG_EVAL
set flags=%includes% -g %debug_versions%

rem set compiler=dmd.exe
set compiler=dmd_msc.exe
rem set compiler=ldmd2.exe

set dtest=rdmd -w -of%binPath%\dtk_test.exe --main -version=DTK_UNITTEST -L/SUBSYSTEM:WINDOWS:5.01 -unittest -g --force --compiler=%compiler% %flags% dtk\package.d

set stdout_log=%buildPath%\dtktest_stdout.log
set stderr_log=%buildPath%\dtktest_stderr.log

echo. > %stdout_log%
echo. > %stderr_log%

%dtest%
if errorlevel 1 GOTO ERROR
type %stdout_log%
echo Success: dtk tested.

%compiler% -g -of%binPath%\dtk.lib -lib %flags% %files% && echo Success: dtk built.
goto :eof

:ERROR
type %stderr_log%
echo Failure: dtk tests failed.
goto :eof

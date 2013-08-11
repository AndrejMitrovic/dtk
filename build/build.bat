@echo off
setlocal EnableDelayedExpansion

set thisPath=%~dp0
set dtkRoot=%thisPath%\..
set binPath=%dtkRoot%\bin
cd %thisPath%\..\src

set "files="
for /r %%i in (*.d) do set files=!files! %%i

set "LIBS_ROOT=%CD%\..\..
IF NOT EXIST %MINILIB_HOME% do set MINILIB_HOME=%LIBS_ROOT%\minilib
IF NOT EXIST %DERELICT3_HOME% do set DERELICT3_HOME=%LIBS_ROOT%\Derelict3
IF NOT EXIST %DEIMOS_GLFW% do set DEIMOS_GLFW=%LIBS_ROOT%\glfw
IF NOT EXIST %GLAD_HOME% do set GLAD_HOME=%LIBS_ROOT%\glad

rem List of -version switches:
rem --------------------------
rem
rem DTK_LOG_EVAL
rem     - Logs all Tcl eval commands.
rem
rem DTK_LOG_TESTS
rem     - Logs all log/logf calls, for use with unittesting.
rem

set includes=-I%cd%
rem set debug_versions=-version=DTK_LOG_EVAL -version=DTK_LOG_TESTS
set debug_versions=
set flags=%includes% -g %debug_versions%

rem set compiler=dmd.exe
set compiler=dmd_msc.exe
rem set compiler=ldmd2.exe

set dtest=rdmd -of%binPath%\dtk_test.exe --main -unittest -g --force --compiler=%compiler% %flags% dtk\package.d

%dtest% && echo Success: dtk tested. && %compiler% -g -of%binPath%\dtk.lib -lib %flags% %files% && echo Success: dtk built.

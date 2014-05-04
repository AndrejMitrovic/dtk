@echo off
set include_dir=C:\Tcl\include
rem dmc test_tk.c -I%include_dir% -otest_dmc.exe && test_dmc.exe
g++ test_tk.c -m32 -I%include_dir% -o test_gcc.exe && test_gcc.exe

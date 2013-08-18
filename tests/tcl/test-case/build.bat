@echo off
set include_dir=C:\Tcl\include
dmc test_tk.c -I%include_dir% -otest_dmc.exe && test_dmc.exe
rem g++ test_tk.c -m32 -I%include_dir% -o test_gcc.exe

@echo off
rem Using rdmd because dub doesn't have a compile-only option
rdmd -vcolumns -Isrc -c src/dtk/package.d

rem dub build --arch=x86
rem dub build --arch=x86_64
rem dub test --arch=x86
rem dub test --arch=x86_64

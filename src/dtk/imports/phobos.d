/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.imports.phobos;

/** Druntime imports. */
public import core.atomic
    : atomicOp;

public import core.exception
    : AssertError;

public import core.memory
    : GC;

public import core.runtime
    : Runtime;

public import core.time
    : dur, Duration, TickDuration;

public import core.thread
    : Thread;

public import core.stdc.config
    : c_long, c_ulong;

public import core.stdc.string
    : memcpy;

/** Phobos imports. */
public import std.algorithm
    : all, startsWith, endsWith, canFind, count, countUntil, find, map, splitter,
      joiner, findSplitBefore, sort, min, max;

public import std.array
    : Appender, array, replace, empty, split;

public import std.ascii
    : isDigit;

public import std.container
    : SList;

public import std.conv
    : phobosTo = to, ConvException, text;

public import std.datetime.stopwatch
    : StopWatch, AutoStart;

public import std.datetime
    : seconds, msecs;

public import std.exception
    : assertThrown, enforce;

public import std.file
    : exists, isFile;

public import std.math
    : isFinite, isNaN;

public import std.path
    : absolutePath, dirSeparator, buildNormalizedPath;

public import std.range
    : front, take, popFront, popFrontN, join, zip, isInputRange, ElementType,
      ElementEncodingType, iota, walkLength;

public import std.stdio
    : stdout, stderr, writeln, writefln;

public import std.string
    : chomp, chompPrefix, lastIndexOf, phobosFormat = format, toStringz, translate;

public alias pointerTarget (T : T*) = T;

public import std.traits
    : isArray, isSomeString, FieldTypeTuple, functionAttributes, FunctionAttribute,
      ParameterStorageClass, ParameterStorageClassTuple, ReturnType,
      isPointer, isSomeFunction, isDelegate, isFunctionPointer, ParameterTypeTuple,
      Unqual, isSomeChar, isStaticArray, EnumMembers, isDynamicArray, hasIndirections;

public import std.typecons
    : scoped;

public import std.typetuple
    : TypeTuple;

public import std.variant
    : Variant;

version (Windows)
{
    public import std.windows.charset
        : fromMBSz;
}

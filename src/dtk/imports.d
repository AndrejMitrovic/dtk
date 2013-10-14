/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.imports;

/** Druntime imports. */
public import core.exception
    : AssertError;

public import core.thread
    : Thread;

public import core.stdc.config
    : c_long, c_ulong;

/** Phobos imports. */
public import std.algorithm
    : all, startsWith, canFind, count, countUntil, find, map, splitter, lastIndexOf,
      joiner;

public import std.array
    : Appender, array, replace, empty;

public import std.container
    : SList;

public import std.conv
    : phobosTo = to, ConvException, text;

public import std.datetime
    : Duration, TickDuration, StopWatch, AutoStart, seconds, msecs;

public import std.exception
    : assertThrown, enforce;

public import std.file
    : exists, isFile;

public import std.math
    : isFinite;

public import std.path
    : absolutePath;

public import std.range
    : front, take, popFront, popFrontN, join, zip, isInputRange, ElementEncodingType;

public import std.stdio
    : stderr;

public import std.string
    : phobosFormat = format, toStringz, translate;

public import std.traits
    : isArray, isSomeString, FieldTypeTuple, functionAttributes, FunctionAttribute,
      ParameterStorageClass, ParameterStorageClassTuple, ReturnType, pointerTarget,
      isPointer, isSomeFunction, isDelegate, isFunctionPointer, ParameterTypeTuple,
      Unqual, isSomeChar, isStaticArray;

public import std.typecons
    : scoped;

public import std.typetuple
    : TypeTuple;

public import std.variant
    : Variant;

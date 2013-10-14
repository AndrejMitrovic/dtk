/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.imports.inline;

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

// ok
public import core.stdc.config
    : c_long, c_ulong;

// ok
public import core.stdc.string
    : memcpy;

/** Phobos imports. */
public import std.algorithm
    : all, startsWith, endsWith, canFind, count, countUntil, find, map, splitter,
      lastIndexOf, joiner, findSplitBefore, sort, min, walkLength, chomp, max,
      chompPrefix;

public import std.array
    : Appender, array, replace, empty, split;

immutable digits         = "0123456789";                 /// 0..9
immutable letters        = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" ~
                           "abcdefghijklmnopqrstuvwxyz"; /// A..Za..z
immutable whitespace     = " \t\v\r\n\f";                /// ASCII whitespace

/++
    Returns whether $(D c) is a digit (0..9).
  +/
bool isDigit(dchar c) @safe pure nothrow
{
    return c <= 0x7F ? cast(bool)(_ctype[c] & _DIG) : false;
}

immutable ubyte[128] _ctype =
[
        _CTL,_CTL,_CTL,_CTL,_CTL,_CTL,_CTL,_CTL,
        _CTL,_CTL|_SPC,_CTL|_SPC,_CTL|_SPC,_CTL|_SPC,_CTL|_SPC,_CTL,_CTL,
        _CTL,_CTL,_CTL,_CTL,_CTL,_CTL,_CTL,_CTL,
        _CTL,_CTL,_CTL,_CTL,_CTL,_CTL,_CTL,_CTL,
        _SPC|_BLK,_PNC,_PNC,_PNC,_PNC,_PNC,_PNC,_PNC,
        _PNC,_PNC,_PNC,_PNC,_PNC,_PNC,_PNC,_PNC,
        _DIG|_HEX,_DIG|_HEX,_DIG|_HEX,_DIG|_HEX,_DIG|_HEX,
        _DIG|_HEX,_DIG|_HEX,_DIG|_HEX,_DIG|_HEX,_DIG|_HEX,
        _PNC,_PNC,_PNC,_PNC,_PNC,_PNC,
        _PNC,_UC|_HEX,_UC|_HEX,_UC|_HEX,_UC|_HEX,_UC|_HEX,_UC|_HEX,_UC,
        _UC,_UC,_UC,_UC,_UC,_UC,_UC,_UC,
        _UC,_UC,_UC,_UC,_UC,_UC,_UC,_UC,
        _UC,_UC,_UC,_PNC,_PNC,_PNC,_PNC,_PNC,
        _PNC,_LC|_HEX,_LC|_HEX,_LC|_HEX,_LC|_HEX,_LC|_HEX,_LC|_HEX,_LC,
        _LC,_LC,_LC,_LC,_LC,_LC,_LC,_LC,
        _LC,_LC,_LC,_LC,_LC,_LC,_LC,_LC,
        _LC,_LC,_LC,_PNC,_PNC,_PNC,_PNC,_CTL
];

enum
{
    _SPC =      8,
    _CTL =      0x20,
    _BLK =      0x40,
    _HEX =      0x80,
    _UC  =      1,
    _LC  =      2,
    _PNC =      0x10,
    _DIG =      4,
    _ALP =      _UC|_LC,
}

public import std.container
    : SList;

public import std.conv
    : phobosTo = to, ConvException, text;

public import std.datetime
    : StopWatch, AutoStart, seconds, msecs;

/++
    Asserts that the given expression throws the given type of $(D Throwable).
    The $(D Throwable) is caught and does not escape assertThrown. However,
    any other $(D Throwable)s $(I will) escape, and if no $(D Throwable)
    of the given type is thrown, then an $(D AssertError) is thrown.

    Params:
        T          = The $(D Throwable) to test for.
        expression = The expression to test.
        msg        = Optional message to output on test failure.
        file       = The file where the error occurred.
                     Defaults to $(D __FILE__).
        line       = The line where the error occurred.
                     Defaults to $(D __LINE__).

    Throws:
        $(D AssertError) if the given $(D Throwable) is not thrown.
  +/
void assertThrown(T : Throwable = Exception, E)
                 (lazy E expression,
                  string msg = null,
                  string file = __FILE__,
                  size_t line = __LINE__)
{
    try
        expression();
    catch (T)
        return;

    throw new AssertError(phobosFormat("assertThrown failed: No %s was thrown%s%s",
                                 T.stringof, msg.empty ? "." : ": ", msg),
                          file, line);
}

/++
    If $(D !!value) is true, $(D value) is returned. Otherwise,
    $(D new Exception(msg)) is thrown.

    Note:
        $(D enforce) is used to throw exceptions and is therefore intended to
        aid in error handling. It is $(I not) intended for verifying the logic
        of your program. That is what $(D assert) is for. Also, do not use
        $(D enforce) inside of contracts (i.e. inside of $(D in) and $(D out)
        blocks and $(D invariant)s), because they will be compiled out when
        compiling with $(I -release). Use $(D assert) in contracts.

    Example:
    --------------------
    auto f = enforce(fopen("data.txt"));
    auto line = readln(f);
    enforce(line.length, "Expected a non-empty line.");
    --------------------
 +/
T enforce(T)(T value, lazy const(char)[] msg = null, string file = __FILE__, size_t line = __LINE__)
{
    if (!value) bailOut(file, line, msg);
    return value;
}

/++
   $(RED Scheduled for deprecation in January 2013. If passing the file or line
         number explicitly, please use the version of enforce which takes them as
         function arguments. Taking them as template arguments causes
         unnecessary template bloat.)
 +/
T enforce(T, string file, size_t line = __LINE__)
    (T value, lazy const(char)[] msg = null)
{
    if (!value) bailOut(file, line, msg);
    return value;
}

/++
    If $(D !!value) is true, $(D value) is returned. Otherwise, the given
    delegate is called.

    The whole safety and purity are inferred from $(D Dg)'s safety and purity.
 +/
T enforce(T, Dg, string file = __FILE__, size_t line = __LINE__)
    (T value, scope Dg dg)
    if (isSomeFunction!Dg && is(typeof( dg() )))
{
    if (!value) dg();
    return value;
}

private void bailOut(string file, size_t line, in char[] msg) @safe pure
{
    throw new Exception(msg ? msg.idup : "Enforcement failed", file, line);
}

public import std.file
    : exists, isFile;

public import std.getopt
    : getoptConfig = config, getopt;

public import std.math
    : isFinite, isNaN;

public import std.path
    : absolutePath, dirSeparator, buildNormalizedPath;

public import std.range
    : front, take, popFront, popFrontN, join, zip, isInputRange, ElementType,
      ElementEncodingType, iota;

public import std.stdio
    : stdout, stderr, writeln, writefln;

public import std.string
    : phobosFormat = format, toStringz, translate;

public import std.traits
    : isArray, isSomeString, FieldTypeTuple, functionAttributes, FunctionAttribute,
      ParameterStorageClass, ParameterStorageClassTuple, ReturnType, pointerTarget,
      isPointer, isSomeFunction, isDelegate, isFunctionPointer, ParameterTypeTuple,
      Unqual, isSomeChar, isStaticArray, EnumMembers, isDynamicArray, hasIndirections;

public import std.typecons
    : scoped;

public import std.typetuple
    : TypeTuple;

public import std.variant
    : Variant;

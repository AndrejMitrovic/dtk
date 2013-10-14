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

/++
    If $(D !!value) is true, $(D value) is returned. Otherwise, $(D ex) is thrown.

    Example:
    --------------------
    auto f = enforce(fopen("data.txt"));
    auto line = readln(f);
    enforce(line.length, new IOException); // expect a non-empty line
    --------------------
 +/
T enforce(T)(T value, lazy Throwable ex)
{
    if (!value) throw ex();
    return value;
}

private void bailOut(string file, size_t line, in char[] msg) @safe pure
{
    throw new Exception(msg ? msg.idup : "Enforcement failed", file, line);
}

version (Windows)
{
    private import dtk.platform.win32.defs
        : GetFileAttributesW, sysErrorString, GetLastError, FILE_ATTRIBUTE_DIRECTORY;
}
else
version (Posix)
{
    private import core.sys.posix.sys.stat
        : stat, stat_t, S_IFMT, S_IFREG, S_IFDIR;
}

private import std.utf
    : toUTF16z;

/++
    Returns whether the given file (or directory) exists.
 +/
bool exists(in char[] name) @trusted
{
    version(Windows)
    {
// http://msdn.microsoft.com/library/default.asp?url=/library/en-us/
// fileio/base/getfileattributes.asp
        return GetFileAttributesW(toUTF16z(name)) != 0xFFFFFFFF;
    }
    else version(Posix)
    {
        /*
            The reason why we use stat (and not access) here is
            the quirky behavior of access for SUID programs: if
            we used access, a file may not appear to "exist",
            despite that the program would be able to open it
            just fine. The behavior in question is described as
            follows in the access man page:

            > The check is done using the calling process's real
            > UID and GID, rather than the effective IDs as is
            > done when actually attempting an operation (e.g.,
            > open(2)) on the file. This allows set-user-ID
            > programs to easily determine the invoking user's
            > authority.

            While various operating systems provide eaccess or
            euidaccess functions, these are not part of POSIX -
            so it's safer to use stat instead.
        */

        stat_t statbuf = void;
        return stat(toStringz(name), &statbuf) == 0;
    }
}

/++
    Returns whether the given file (or directory) is a file.

    On Windows, if a file is not a directory, then it's a file. So,
    either $(D isFile) or $(D isDir) will return true for any given file.

    On Posix systems, if $(D isFile) is $(D true), that indicates that the file
    is a regular file (e.g. not a block not device). So, on Posix systems, it's
    possible for both $(D isFile) and $(D isDir) to be $(D false) for a
    particular file (in which case, it's a special file). You can use
    $(D getAttributes) to get the attributes to figure out what type of special
    it is, or you can use $(D DirEntry) to get at its $(D statBuf), which is the
    result from $(D stat). In either case, see the man page for $(D stat) for
    more information.

    Params:
        name = The path to the file.

    Throws:
        $(D FileException) if the given file does not exist.

Examples:
--------------------
assert("/etc/fonts/fonts.conf".isFile);
assert(!"/usr/share/include".isFile);
--------------------
  +/
@property bool isFile(in char[] name)
{
    version(Windows)
        return !name.isDir;
    else version(Posix)
        return (getAttributes(name) & S_IFMT) == S_IFREG;
}

/++
    Returns whether the given file is a directory.

    Params:
        name = The path to the file.

    Throws:
        $(D FileException) if the given file does not exist.

Examples:
--------------------
assert(!"/etc/fonts/fonts.conf".isDir);
assert("/usr/share/include".isDir);
--------------------
  +/
@property bool isDir(in char[] name)
{
    version(Windows)
    {
        return (getAttributes(name) & FILE_ATTRIBUTE_DIRECTORY) != 0;
    }
    else version(Posix)
    {
        return (getAttributes(name) & S_IFMT) == S_IFDIR;
    }
}

/++
 Returns the attributes of the given file.

 Note that the file attributes on Windows and Posix systems are
 completely different. On Windows, they're what is returned by $(WEB
 msdn.microsoft.com/en-us/library/aa364944(v=vs.85).aspx,
 GetFileAttributes), whereas on Posix systems, they're the $(LUCKY
 st_mode) value which is part of the $(D stat struct) gotten by
 calling the $(WEB en.wikipedia.org/wiki/Stat_%28Unix%29, $(D stat))
 function.

 On Posix systems, if the given file is a symbolic link, then
 attributes are the attributes of the file pointed to by the symbolic
 link.

 Params:
 name = The file to get the attributes of.

 Throws: $(D FileException) on error.
  +/
uint getAttributes(in char[] name)
{
    version(Windows)
    {
        immutable result = GetFileAttributesW(toUTF16z(name));

        enforce(result != uint.max, new FileException(name.idup));

        return result;
    }
    else version(Posix)
    {
        stat_t statbuf = void;

        cenforce(stat(toStringz(name), &statbuf) == 0, name);

        return statbuf.st_mode;
    }
}

/++
    Exception thrown for file I/O errors.
 +/
class FileException : Exception
{
    /++
        OS error code.
     +/
    immutable uint errno;

    /++
        Constructor which takes an error message.

        Params:
            name = Name of file for which the error occurred.
            msg  = Message describing the error.
            file = The file where the error occurred.
            line = The line where the error occurred.
     +/
    this(in char[] name, in char[] msg, string file = __FILE__, size_t line = __LINE__) @safe pure
    {
        if(msg.empty)
            super(name.idup, file, line);
        else
            super(text(name, ": ", msg), file, line);

        errno = 0;
    }

    /++
        Constructor which takes the error number ($(LUCKY GetLastError)
        in Windows, $(D_PARAM errno) in Posix).

        Params:
            name  = Name of file for which the error occurred.
            errno = The error number.
            file  = The file where the error occurred.
                    Defaults to $(D __FILE__).
            line  = The line where the error occurred.
                    Defaults to $(D __LINE__).
     +/
    version(Windows) this(in char[] name,
                          uint errno = .GetLastError(),
                          string file = __FILE__,
                          size_t line = __LINE__) @safe
    {
        this(name, sysErrorString(errno), file, line);
        this.errno = errno;
    }
    else version(Posix) this(in char[] name,
                             uint errno = .errno,
                             string file = __FILE__,
                             size_t line = __LINE__) @trusted
    {
        auto s = strerror(errno);
        this(name, phobosTo!string(s), file, line);
        this.errno = errno;
    }
}

private T cenforce(T)(T condition, lazy const(char)[] name, string file = __FILE__, size_t line = __LINE__)
{
    if (!condition)
    {
        version (Windows)
        {
            throw new FileException(name, .GetLastError(), file, line);
        }
        else version (Posix)
        {
            throw new FileException(name, .errno, file, line);
        }
    }
    return condition;
}

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

version (Windows)
{
    public import std.windows.charset
        : fromMBSz;
}

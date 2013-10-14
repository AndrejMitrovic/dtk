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

private import std.algorithm
    : move;

private import std.range
    : Take, isForwardRange;

/**
   Implements a simple and fast singly-linked list.
 */
struct SList(T)
{
    private struct Node
    {
        T _payload;
        Node * _next;
        this(T a, Node* b) { _payload = a; _next = b; }
    }
    private Node * _root;

    private static Node * findLastNode(Node * n)
    {
        assert(n);
        auto ahead = n._next;
        while (ahead)
        {
            n = ahead;
            ahead = n._next;
        }
        return n;
    }

    private static Node * findLastNode(Node * n, size_t limit)
    {
        assert(n && limit);
        auto ahead = n._next;
        while (ahead)
        {
            if (!--limit) break;
            n = ahead;
            ahead = n._next;
        }
        return n;
    }

    private static Node * findNode(Node * n, Node * findMe)
    {
        assert(n);
        auto ahead = n._next;
        while (ahead != findMe)
        {
            n = ahead;
            enforce(n);
            ahead = n._next;
        }
        return n;
    }

/**
Constructor taking a number of nodes
     */
    this(U)(U[] values...) if (isImplicitlyConvertible!(U, T))
    {
        insertFront(values);
    }

/**
Constructor taking an input range
     */
    this(Stuff)(Stuff stuff)
    if (isInputRange!Stuff
            && isImplicitlyConvertible!(ElementType!Stuff, T)
            && !is(Stuff == T[]))
    {
        insertFront(stuff);
    }

/**
Comparison for equality.

Complexity: $(BIGOH min(n, n1)) where $(D n1) is the number of
elements in $(D rhs).
     */
    bool opEquals(const SList rhs) const
    {
        return opEquals(rhs);
    }

    /// ditto
    bool opEquals(ref const SList rhs) const
    {
        const(Node) * n1 = _root, n2 = rhs._root;

        for (;; n1 = n1._next, n2 = n2._next)
        {
            if (!n1) return !n2;
            if (!n2 || n1._payload != n2._payload) return false;
        }
    }

/**
Defines the container's primary range, which embodies a forward range.
     */
    struct Range
    {
        private Node * _head;
        private this(Node * p) { _head = p; }

        /// Input range primitives.
        @property bool empty() const { return !_head; }

        /// ditto
        @property T front()
        {
            assert(!empty, "SList.Range.front: Range is empty");
            return _head._payload;
        }

        /// ditto
        static if (isAssignable!(T, T))
        {
            @property void front(T value)
            {
                assert(!empty, "SList.Range.front: Range is empty");
                move(value, _head._payload);
            }
        }

        /// ditto
        void popFront()
        {
            assert(!empty, "SList.Range.popFront: Range is empty");
            _head = _head._next;
        }

        /// Forward range primitive.
        @property Range save() { return this; }

        T moveFront()
        {
            assert(!empty, "SList.Range.moveFront: Range is empty");
            return move(_head._payload);
        }

        bool sameHead(Range rhs)
        {
            return _head && _head == rhs._head;
        }
    }

    unittest
    {
        static assert(isForwardRange!Range);
    }

/**
Property returning $(D true) if and only if the container has no
elements.

Complexity: $(BIGOH 1)
     */
    @property bool empty() const
    {
        return _root is null;
    }

/**
Duplicates the container. The elements themselves are not transitively
duplicated.

Complexity: $(BIGOH n).
     */
    @property SList dup()
    {
        return SList(this[]);
    }

/**
Returns a range that iterates over all elements of the container, in
forward order.

Complexity: $(BIGOH 1)
     */
    Range opSlice()
    {
        return Range(_root);
    }

/**
Forward to $(D opSlice().front).

Complexity: $(BIGOH 1)
     */
    @property T front()
    {
        assert(!empty, "SList.front: List is empty");
        return _root._payload;
    }

/**
Forward to $(D opSlice().front(value)).

Complexity: $(BIGOH 1)
     */
    static if (isAssignable!(T, T))
    {
        @property void front(T value)
        {
            assert(!empty, "SList.front: List is empty");
            move(value, _root._payload);
        }
    }

    unittest
    {
        auto s = SList!int(1, 2, 3);
        s.front = 42;
        assert(s == SList!int(42, 2, 3));
    }

/**
Returns a new $(D SList) that's the concatenation of $(D this) and its
argument. $(D opBinaryRight) is only defined if $(D Stuff) does not
define $(D opBinary).
     */
    SList opBinary(string op, Stuff)(Stuff rhs)
    if (op == "~" && is(typeof(SList(rhs))))
    {
        auto toAdd = SList(rhs);
        static if (is(Stuff == SList))
        {
            toAdd = toAdd.dup;
        }
        if (empty) return toAdd;
        // TODO: optimize
        auto result = dup;
        auto n = findLastNode(result._root);
        n._next = toAdd._root;
        return result;
    }

/**
Removes all contents from the $(D SList).

Postcondition: $(D empty)

Complexity: $(BIGOH 1)
     */
    void clear()
    {
        _root = null;
    }

/**
Inserts $(D stuff) to the front of the container. $(D stuff) can be a
value convertible to $(D T) or a range of objects convertible to $(D
T). The stable version behaves the same, but guarantees that ranges
iterating over the container are never invalidated.

Returns: The number of elements inserted

Complexity: $(BIGOH m), where $(D m) is the length of $(D stuff)
     */
    size_t insertFront(Stuff)(Stuff stuff)
    if (isInputRange!Stuff && isImplicitlyConvertible!(ElementType!Stuff, T))
    {
        size_t result;
        Node * n, newRoot;
        foreach (item; stuff)
        {
            auto newNode = new Node(item, null);
            (newRoot ? n._next : newRoot) = newNode;
            n = newNode;
            ++result;
        }
        if (!n) return 0;
        // Last node points to the old root
        n._next = _root;
        _root = newRoot;
        return result;
    }

    /// ditto
    size_t insertFront(Stuff)(Stuff stuff)
    if (isImplicitlyConvertible!(Stuff, T))
    {
        auto newRoot = new Node(stuff, _root);
        _root = newRoot;
        return 1;
    }

/// ditto
    alias insertFront insert;

/// ditto
    alias insert stableInsert;

    /// ditto
    alias insertFront stableInsertFront;

/**
Picks one value from the front of the container, removes it from the
container, and returns it.

Precondition: $(D !empty)

Returns: The element removed.

Complexity: $(BIGOH 1).
     */
    T removeAny()
    {
        assert(!empty, "SList.removeAny: List is empty");
        auto result = move(_root._payload);
        _root = _root._next;
        return result;
    }
    /// ditto
    alias removeAny stableRemoveAny;

/**
Removes the value at the front of the container. The stable version
behaves the same, but guarantees that ranges iterating over the
container are never invalidated.

Precondition: $(D !empty)

Complexity: $(BIGOH 1).
     */
    void removeFront()
    {
        assert(!empty, "SList.removeFront: List is empty");
        _root = _root._next;
    }

    /// ditto
    alias removeFront stableRemoveFront;

/**
Removes $(D howMany) values at the front or back of the
container. Unlike the unparameterized versions above, these functions
do not throw if they could not remove $(D howMany) elements. Instead,
if $(D howMany > n), all elements are removed. The returned value is
the effective number of elements removed. The stable version behaves
the same, but guarantees that ranges iterating over the container are
never invalidated.

Returns: The number of elements removed

Complexity: $(BIGOH howMany * log(n)).
     */
    size_t removeFront(size_t howMany)
    {
        size_t result;
        while (_root && result < howMany)
        {
            _root = _root._next;
            ++result;
        }
        return result;
    }

    /// ditto
    alias removeFront stableRemoveFront;

/**
Inserts $(D stuff) after range $(D r), which must be a range
previously extracted from this container. Given that all ranges for a
list end at the end of the list, this function essentially appends to
the list and uses $(D r) as a potentially fast way to reach the last
node in the list. Ideally $(D r) is positioned near or at the last
element of the list.

$(D stuff) can be a value convertible to $(D T) or a range of objects
convertible to $(D T). The stable version behaves the same, but
guarantees that ranges iterating over the container are never
invalidated.

Returns: The number of values inserted.

Complexity: $(BIGOH k + m), where $(D k) is the number of elements in
$(D r) and $(D m) is the length of $(D stuff).

Examples:
--------------------
auto sl = SList!string(["a", "b", "d"]);
sl.insertAfter(sl[], "e"); // insert at the end (slowest)
assert(std.algorithm.equal(sl[], ["a", "b", "d", "e"]));
sl.insertAfter(std.range.take(sl[], 2), "c"); // insert after "b"
assert(std.algorithm.equal(sl[], ["a", "b", "c", "d", "e"]));
--------------------
     */

    size_t insertAfter(Stuff)(Range r, Stuff stuff)
    {
        if (!_root)
        {
            enforce(!r._head);
            return insertFront(stuff);
        }
        enforce(r._head);
        auto n = findLastNode(r._head);
        SList tmp;
        auto result = tmp.insertFront(stuff);
        n._next = tmp._root;
        return result;
    }

/**
Similar to $(D insertAfter) above, but accepts a range bounded in
count. This is important for ensuring fast insertions in the middle of
the list.  For fast insertions after a specified position $(D r), use
$(D insertAfter(take(r, 1), stuff)). The complexity of that operation
only depends on the number of elements in $(D stuff).

Precondition: $(D r.original.empty || r.maxLength > 0)

Returns: The number of values inserted.

Complexity: $(BIGOH k + m), where $(D k) is the number of elements in
$(D r) and $(D m) is the length of $(D stuff).
     */
    size_t insertAfter(Stuff)(Take!Range r, Stuff stuff)
    {
        auto orig = r.source;
        if (!orig._head)
        {
            // Inserting after a null range counts as insertion to the
            // front
            return insertFront(stuff);
        }
        enforce(!r.empty);
        // Find the last valid element in the range
        foreach (i; 1 .. r.maxLength)
        {
            if (!orig._head._next) break;
            orig.popFront();
        }
        // insert here
        SList tmp;
        tmp._root = orig._head._next;
        auto result = tmp.insertFront(stuff);
        orig._head._next = tmp._root;
        return result;
    }

/// ditto
    alias insertAfter stableInsertAfter;

/**
Removes a range from the list in linear time.

Returns: An empty range.

Complexity: $(BIGOH n)
     */
    Range linearRemove(Range r)
    {
        if (!_root)
        {
            enforce(!r._head);
            return this[];
        }
        auto n = findNode(_root, r._head);
        n._next = null;
        return Range(null);
    }

/**
Removes a $(D Take!Range) from the list in linear time.

Returns: A range comprehending the elements after the removed range.

Complexity: $(BIGOH n)
     */
    Range linearRemove(Take!Range r)
    {
        auto orig = r.source;
        // We have something to remove here
        if (orig._head == _root)
        {
            // remove straight from the head of the list
            for (; !r.empty; r.popFront())
            {
                removeFront();
            }
            return this[];
        }
        if (!r.maxLength)
        {
            // Nothing to remove, return the range itself
            return orig;
        }
        // Remove from somewhere in the middle of the list
        enforce(_root);
        auto n1 = findNode(_root, orig._head);
        auto n2 = findLastNode(orig._head, r.maxLength);
        n1._next = n2._next;
        return Range(n1._next);
    }

/// ditto
    alias linearRemove stableLinearRemove;
}

/**
Returns $(D true) iff a value of type $(D Rhs) can be assigned to a variable of
type $(D Lhs).

If you omit $(D Rhs), $(D isAssignable) will check identity assignable of $(D Lhs).

Examples:
---
static assert(isAssignable!(long, int));
static assert(!isAssignable!(int, long));
static assert( isAssignable!(const(char)[], string));
static assert(!isAssignable!(string, char[]));

// int is assignable to int
static assert( isAssignable!int);

// immutable int is not assinable to immutable int
static assert(!isAssignable!(immutable int));
---
*/
template isAssignable(Lhs, Rhs = Lhs)
{
    enum bool isAssignable = is(typeof({
        Lhs l = void;
        void f(Rhs r) { l = r; }
        return l;
    }));
}

/**
Is $(D From) implicitly convertible to $(D To)?
 */
template isImplicitlyConvertible(From, To)
{
    enum bool isImplicitlyConvertible = is(typeof({
        void fun(ref From v)
        {
            void gun(To) {}
            gun(v);
        }
    }));
}

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

wchar* toUTF16z(in char[] input)
{
    return cast(wchar*)(phobosTo!wstring(input) ~ "\0").ptr;
}

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

/*********************************
 * Returns !=0 if e is a NaN.
 */

bool isNaN(real x) @trusted pure nothrow
{
    alias floatTraits!(real) F;
    static if (real.mant_dig == 53) // double
    {
        ulong*  p = cast(ulong *)&x;
        return ((*p & 0x7FF0_0000_0000_0000) == 0x7FF0_0000_0000_0000)
        && *p & 0x000F_FFFF_FFFF_FFFF;
    }
    else static if (real.mant_dig == 64)  // real80
    {
        ushort e = F.EXPMASK & (cast(ushort *)&x)[F.EXPPOS_SHORT];
        ulong*  ps = cast(ulong *)&x;
        return e == F.EXPMASK &&
        *ps & 0x7FFF_FFFF_FFFF_FFFF; // not infinity
    }
    else static if (real.mant_dig == 113) // quadruple
    {
        ushort e = F.EXPMASK & (cast(ushort *)&x)[F.EXPPOS_SHORT];
        ulong*  ps = cast(ulong *)&x;
        return e == F.EXPMASK &&
        (ps[MANTISSA_LSB] | (ps[MANTISSA_MSB]& 0x0000_FFFF_FFFF_FFFF))!=0;
    }
    else
    {
        return x!=x;
    }
}

int isFinite(real e) @trusted pure nothrow
{
    alias floatTraits!(real) F;
    ushort* pe = cast(ushort *)&e;
    return (pe[F.EXPPOS_SHORT] & F.EXPMASK) != F.EXPMASK;
}

// Constants used for extracting the components of the representation.
// They supplement the built-in floating point properties.
template floatTraits(T)
{
    // EXPMASK is a ushort mask to select the exponent portion (without sign)
    // EXPPOS_SHORT is the index of the exponent when represented as a ushort array.
    // SIGNPOS_BYTE is the index of the sign when represented as a ubyte array.
    // RECIP_EPSILON is the value such that (smallest_subnormal) * RECIP_EPSILON == T.min_normal
    enum T RECIP_EPSILON = (1/T.epsilon);
    static if (T.mant_dig == 24)
    { // float
        enum ushort EXPMASK = 0x7F80;
        enum ushort EXPBIAS = 0x3F00;
        enum uint EXPMASK_INT = 0x7F80_0000;
        enum uint MANTISSAMASK_INT = 0x007F_FFFF;
        version(LittleEndian)
        {
            enum EXPPOS_SHORT = 1;
        }
        else
        {
            enum EXPPOS_SHORT = 0;
        }
    }
    else static if (T.mant_dig == 53) // double, or real==double
    {
        enum ushort EXPMASK = 0x7FF0;
        enum ushort EXPBIAS = 0x3FE0;
        enum uint EXPMASK_INT = 0x7FF0_0000;
        enum uint MANTISSAMASK_INT = 0x000F_FFFF; // for the MSB only
        version(LittleEndian)
        {
            enum EXPPOS_SHORT = 3;
            enum SIGNPOS_BYTE = 7;
        }
        else
        {
            enum EXPPOS_SHORT = 0;
            enum SIGNPOS_BYTE = 0;
        }
    }
    else static if (T.mant_dig == 64) // real80
    {
        enum ushort EXPMASK = 0x7FFF;
        enum ushort EXPBIAS = 0x3FFE;
        version(LittleEndian)
        {
            enum EXPPOS_SHORT = 4;
            enum SIGNPOS_BYTE = 9;
        }
        else
        {
            enum EXPPOS_SHORT = 0;
            enum SIGNPOS_BYTE = 0;
        }
    }
    else static if (T.mant_dig == 113) // quadruple
    {
        enum ushort EXPMASK = 0x7FFF;
        version(LittleEndian)
        {
            enum EXPPOS_SHORT = 7;
            enum SIGNPOS_BYTE = 15;
        }
        else
        {
            enum EXPPOS_SHORT = 0;
            enum SIGNPOS_BYTE = 0;
        }
    }
    else static if (T.mant_dig == 106) // doubledouble
    {
        enum ushort EXPMASK = 0x7FF0;
        // the exponent byte is not unique
        version(LittleEndian)
        {
            enum EXPPOS_SHORT = 7; // [3] is also an exp short
            enum SIGNPOS_BYTE = 15;
        }
        else
        {
            enum EXPPOS_SHORT = 0; // [4] is also an exp short
            enum SIGNPOS_BYTE = 0;
        }
    }
}

// These apply to all floating-point types
version(LittleEndian)
{
    enum MANTISSA_LSB = 0;
    enum MANTISSA_MSB = 1;
}
else
{
    enum MANTISSA_LSB = 1;
    enum MANTISSA_MSB = 0;
}

public import std.path
    : absolutePath, dirSeparator, buildNormalizedPath;

public import std.range
    : front, take, popFront, popFrontN, join, zip, isInputRange, ElementType,
      ElementEncodingType, iota;

public import std.stdio
    : stdout, stderr, writeln, writefln;

public import std.string
    : phobosFormat = format, toStringz, translate;

/**
 * Detect whether type $(D T) is an array.
 */
template isArray(T)
{
    enum bool isArray = isStaticArray!T || isDynamicArray!T;
}

/**
 * Detect whether type $(D T) is a static array.
 */
template isStaticArray(T)
{
    enum isStaticArray = is(StaticArrayTypeOf!T) && !isAggregateType!T;
}

/*
 */
template StaticArrayTypeOf(T)
{
    inout(U[n]) idx(U, size_t n)( inout(U[n]) );

    static if (is(T == enum))
        alias .StaticArrayTypeOf!(OriginalType!T) StaticArrayTypeOf;
    else static if (is(typeof(idx(defaultInit!T)) X))
        alias X StaticArrayTypeOf;
    else
        static assert(0, T.stringof~" is not a static array type");
}

/**
Strips off all $(D typedef)s (including $(D enum) ones) from type $(D T).

Example:
--------------------
enum E : int { a }
typedef E F;
typedef const F G;
static assert(is(OriginalType!G == const int));
--------------------
 */
template OriginalType(T)
{
    template Impl(T)
    {
             static if (is(T U == typedef)) alias OriginalType!U Impl;
        else static if (is(T U ==    enum)) alias OriginalType!U Impl;
        else                                alias              T Impl;
    }

    alias ModifyTypePreservingSTC!(Impl, T) OriginalType;
}

// [For internal use]
private template ModifyTypePreservingSTC(alias Modifier, T)
{
         static if (is(T U == shared(inout U))) alias shared(inout Modifier!U) ModifyTypePreservingSTC;
    else static if (is(T U == shared(const U))) alias shared(const Modifier!U) ModifyTypePreservingSTC;
    else static if (is(T U ==        inout U )) alias        inout(Modifier!U) ModifyTypePreservingSTC;
    else static if (is(T U ==        const U )) alias        const(Modifier!U) ModifyTypePreservingSTC;
    else static if (is(T U ==    immutable U )) alias    immutable(Modifier!U) ModifyTypePreservingSTC;
    else static if (is(T U ==       shared U )) alias       shared(Modifier!U) ModifyTypePreservingSTC;
    else                                        alias              Modifier!T  ModifyTypePreservingSTC;
}

/**
 * Detect whether type $(D T) is an aggregate type.
 */
template isAggregateType(T)
{
    enum isAggregateType = is(T == struct) || is(T == union) ||
                           is(T == class) || is(T == interface);
}

/**
 * Detect whether type $(D T) is a dynamic array.
 */
template isDynamicArray(T)
{
    enum isDynamicArray = is(DynamicArrayTypeOf!T) && !isAggregateType!T;
}

/*
 */
template DynamicArrayTypeOf(T)
{
    inout(U[]) idx(U)( inout(U[]) );

    static if (is(T == enum))
        alias .DynamicArrayTypeOf!(OriginalType!T) DynamicArrayTypeOf;
    else static if (!is(StaticArrayTypeOf!T) &&
                     is(typeof(idx(defaultInit!T)) X))
    {
        alias typeof(defaultInit!T[0]) E;

                     E[]  idy(              E[]  );
               const(E[]) idy(        const(E[]) );
               inout(E[]) idy(        inout(E[]) );
        shared(      E[]) idy( shared(      E[]) );
        shared(const E[]) idy( shared(const E[]) );
        shared(inout E[]) idy( shared(inout E[]) );
           immutable(E[]) idy(    immutable(E[]) );

        alias typeof(idy(defaultInit!T)) DynamicArrayTypeOf;
    }
    else
        static assert(0, T.stringof~" is not a dynamic array");
}

/* Get an expression typed as T, like T.init */
template defaultInit(T)
{
    static if (!is(typeof({ T v = void; })))    // inout(U)
        @property T defaultInit(T v = T.init);
    else
        @property T defaultInit();
}

/***
 * Get the type of the return value from a function,
 * a pointer to function, a delegate, a struct
 * with an opCall, a pointer to a struct with an opCall,
 * or a class with an $(D opCall). Please note that $(D_KEYWORD ref)
 * is not part of a type, but the attribute of the function
 * (see template $(LREF functionAttributes)).
 * Example:
 * ---
 * int foo();
 * ReturnType!foo x;   // x is declared as int
 * ---
 */
template ReturnType(func...)
    if (func.length == 1 && isCallable!func)
{
    static if (is(FunctionTypeOf!func R == return))
        alias R ReturnType;
    else
        static assert(0, "argument has no return type");
}

/**
Get the function type from a callable object $(D func).

Using builtin $(D typeof) on a property function yields the types of the
property value, not of the property function itself.  Still,
$(D FunctionTypeOf) is able to obtain function types of properties.
--------------------
class C
{
    int value() @property;
}
static assert(is( typeof(C.value) == int ));
static assert(is( FunctionTypeOf!(C.value) == function ));
--------------------

Note:
Do not confuse function types with function pointer types; function types are
usually used for compile-time reflection purposes.
 */
template FunctionTypeOf(func...)
    if (func.length == 1 && isCallable!func)
{
    static if (is(typeof(& func[0]) Fsym : Fsym*) && is(Fsym == function) || is(typeof(& func[0]) Fsym == delegate))
    {
        alias Fsym FunctionTypeOf; // HIT: (nested) function symbol
    }
    else static if (is(typeof(& func[0].opCall) Fobj == delegate))
    {
        alias Fobj FunctionTypeOf; // HIT: callable object
    }
    else static if (is(typeof(& func[0].opCall) Ftyp : Ftyp*) && is(Ftyp == function))
    {
        alias Ftyp FunctionTypeOf; // HIT: callable type
    }
    else static if (is(func[0] T) || is(typeof(func[0]) T))
    {
        static if (is(T == function))
            alias T    FunctionTypeOf; // HIT: function
        else static if (is(T Fptr : Fptr*) && is(Fptr == function))
            alias Fptr FunctionTypeOf; // HIT: function pointer
        else static if (is(T Fdlg == delegate))
            alias Fdlg FunctionTypeOf; // HIT: delegate
        else static assert(0);
    }
    else static assert(0);
}

/**
Detect whether $(D T) is a callable object, which can be called with the
function call operator $(D $(LPAREN)...$(RPAREN)).
 */
template isCallable(T...)
    if (T.length == 1)
{
    static if (is(typeof(& T[0].opCall) == delegate))
        // T is a object which has a member function opCall().
        enum bool isCallable = true;
    else static if (is(typeof(& T[0].opCall) V : V*) && is(V == function))
        // T is a type which has a static member function opCall().
        enum bool isCallable = true;
    else
        enum bool isCallable = isSomeFunction!T;
}

/**
Detect whether $(D T) is one of the built-in string types.
 */
template isSomeString(T)
{
    enum isSomeString = is(StringTypeOf!T) && !isAggregateType!T;
}

/*
 */
template StringTypeOf(T)
{
    static if (is(T == typeof(null)))
    {
        // It is impossible to determine exact string type from typeof(null) -
        // it means that StringTypeOf!(typeof(null)) is undefined.
        // Then this behavior is convenient for template constraint.
        static assert(0, T.stringof~" is not a string type");
    }
    else static if (is(T : const char[]) || is(T : const wchar[]) || is(T : const dchar[]))
    {
        alias ArrayTypeOf!T StringTypeOf;
    }
    else
        static assert(0, T.stringof~" is not a string type");
}

/*
 */
template ArrayTypeOf(T)
{
    static if (is(StaticArrayTypeOf!T X))
        alias X ArrayTypeOf;
    else static if (is(DynamicArrayTypeOf!T X))
        alias X ArrayTypeOf;
    else
        static assert(0, T.stringof~" is not an array type");
}

/***
 * Get as a typetuple the types of the fields of a struct, class, or union.
 * This consists of the fields that take up memory space,
 * excluding the hidden fields like the virtual function
 * table pointer or a context pointer for nested types.
 * If $(D T) isn't a struct, class, or union returns typetuple
 * with one element $(D T).
 */
template FieldTypeTuple(T)
{
    static if (is(T == struct) || is(T == union))
        alias typeof(T.tupleof[0 .. $ - isNested!T]) FieldTypeTuple;
    else static if (is(T == class))
        alias typeof(T.tupleof) FieldTypeTuple;
    else
        alias TypeTuple!T FieldTypeTuple;
}

/**
Determines whether $(D T) has its own context pointer.
$(D T) must be either $(D class), $(D struct), or $(D union).
*/
template isNested(T)
    if(is(T == class) || is(T == struct) || is(T == union))
{
    enum isNested = __traits(isNested, T);
}

/**
 * Detect whether type $(D T) is a pointer.
 */
template isPointer(T)
{
    static if (is(T P == U*, U) && !isAggregateType!T)
        enum isPointer = true;
    else
        enum isPointer = false;
}

/**
Detect whether symbol or type $(D T) is a delegate.
*/
template isDelegate(T...)
    if (T.length == 1)
{
    static if (is(typeof(& T[0]) U : U*) && is(typeof(& T[0]) U == delegate))
    {
        // T is a (nested) function symbol.
        enum bool isDelegate = true;
    }
    else static if (is(T[0] W) || is(typeof(T[0]) W))
    {
        // T is an expression or a type.  Take the type of it and examine.
        enum bool isDelegate = is(W == delegate);
    }
    else
        enum bool isDelegate = false;
}

/**
Detect whether symbol or type $(D T) is a function pointer.
 */
template isFunctionPointer(T...)
    if (T.length == 1)
{
    static if (is(T[0] U) || is(typeof(T[0]) U))
    {
        static if (is(U F : F*) && is(F == function))
            enum bool isFunctionPointer = true;
        else
            enum bool isFunctionPointer = false;
    }
    else
        enum bool isFunctionPointer = false;
}

/**
Detect whether $(D T) is one of the built-in character types.
 */
template isSomeChar(T)
{
    enum isSomeChar = is(CharTypeOf!T) && !isAggregateType!T;
}

/*
 */
template CharTypeOf(T)
{
           inout( char) idx(        inout( char) );
           inout(wchar) idx(        inout(wchar) );
           inout(dchar) idx(        inout(dchar) );
    shared(inout  char) idx( shared(inout  char) );
    shared(inout wchar) idx( shared(inout wchar) );
    shared(inout dchar) idx( shared(inout dchar) );

      immutable(  char) idy(   immutable(  char) );
      immutable( wchar) idy(   immutable( wchar) );
      immutable( dchar) idy(   immutable( dchar) );
    // Integrals and characers are implicitly convertible with each other for value copy.
    // Then adding exact overloads to detect it.
      immutable(  byte) idy(   immutable(  byte) );
      immutable( ubyte) idy(   immutable( ubyte) );
      immutable( short) idy(   immutable( short) );
      immutable(ushort) idy(   immutable(ushort) );
      immutable(   int) idy(   immutable(   int) );
      immutable(  uint) idy(   immutable(  uint) );

    static if (is(T == enum))
        alias .CharTypeOf!(OriginalType!T) CharTypeOf;
    else static if (is(typeof(idx(T.init)) X))
        alias X CharTypeOf;
    else static if (is(typeof(idy(T.init)) X) && staticIndexOf!(Unqual!X, CharTypeList) >= 0)
        alias X CharTypeOf;
    else
        static assert(0, T.stringof~" is not a character type");
}

/**
 * Returns the index of the first occurrence of type T in the
 * sequence of zero or more types TList.
 * If not found, -1 is returned.
 */
template staticIndexOf(T, TList...)
{
    enum staticIndexOf = genericIndexOf!(T, TList).index;
}

/// Ditto
template staticIndexOf(alias T, TList...)
{
    enum staticIndexOf = genericIndexOf!(T, TList).index;
}

/**
Removes all qualifiers, if any, from type $(D T).

Example:
----
static assert(is(Unqual!int == int));
static assert(is(Unqual!(const int) == int));
static assert(is(Unqual!(immutable int) == int));
static assert(is(Unqual!(shared int) == int));
static assert(is(Unqual!(shared(const int)) == int));
----
 */
template Unqual(T)
{
    version (none) // Error: recursive alias declaration @@@BUG1308@@@
    {
             static if (is(T U ==     const U)) alias Unqual!U Unqual;
        else static if (is(T U == immutable U)) alias Unqual!U Unqual;
        else static if (is(T U ==     inout U)) alias Unqual!U Unqual;
        else static if (is(T U ==    shared U)) alias Unqual!U Unqual;
        else                                    alias        T Unqual;
    }
    else // workaround
    {
             static if (is(T U == shared(inout U))) alias U Unqual;
        else static if (is(T U == shared(const U))) alias U Unqual;
        else static if (is(T U ==        inout U )) alias U Unqual;
        else static if (is(T U ==        const U )) alias U Unqual;
        else static if (is(T U ==    immutable U )) alias U Unqual;
        else static if (is(T U ==       shared U )) alias U Unqual;
        else                                        alias T Unqual;
    }
}

/***
Get, as a tuple, the types of the parameters to a function, a pointer
to function, a delegate, a struct with an $(D opCall), a pointer to a
struct with an $(D opCall), or a class with an $(D opCall).

Example:
---
int foo(int, long);
void bar(ParameterTypeTuple!foo);      // declares void bar(int, long);
void abc(ParameterTypeTuple!foo[1]);   // declares void abc(long);
---
*/
template ParameterTypeTuple(func...)
    if (func.length == 1 && isCallable!func)
{
    static if (is(FunctionTypeOf!func P == function))
        alias P ParameterTypeTuple;
    else
        static assert(0, "argument has no parameters");
}

/**
Returns the target type of a pointer.
*/
template PointerTarget(T : T*)
{
    alias T PointerTarget;
}

/// $(RED Scheduled for deprecation. Please use $(LREF PointerTarget) instead.)
alias PointerTarget pointerTarget;

/**
Detect whether symbol or type $(D T) is a function, a function pointer or a delegate.
 */
template isSomeFunction(T...)
    if (T.length == 1)
{
    static if (is(typeof(& T[0]) U : U*) && is(U == function) || is(typeof(& T[0]) U == delegate))
    {
        // T is a (nested) function symbol.
        enum bool isSomeFunction = true;
    }
    else static if (is(T[0] W) || is(typeof(T[0]) W))
    {
        // T is an expression or a type.  Take the type of it and examine.
        static if (is(W F : F*) && is(F == function))
            enum bool isSomeFunction = true; // function pointer
        else
            enum bool isSomeFunction = is(W == function) || is(W == delegate);
    }
    else
        enum bool isSomeFunction = false;
}

/**
Retrieves the members of an enumerated type $(D enum E).

Params:
 E = An enumerated type. $(D E) may have duplicated values.

Returns:
 Static tuple composed of the members of the enumerated type $(D E).
 The members are arranged in the same order as declared in $(D E).

Note:
 An enum can have multiple members which have the same value. If you want
 to use EnumMembers to e.g. generate switch cases at compile-time,
 you should use the $(XREF typetuple, NoDuplicates) template to avoid
 generating duplicate switch cases.

Note:
 Returned values are strictly typed with $(D E). Thus, the following code
 does not work without the explicit cast:
--------------------
enum E : int { a, b, c }
int[] abc = cast(int[]) [ EnumMembers!E ];
--------------------
 Cast is not necessary if the type of the variable is inferred. See the
 example below.

Examples:
 Creating an array of enumerated values:
--------------------
enum Sqrts : real
{
    one   = 1,
    two   = 1.41421,
    three = 1.73205,
}
auto sqrts = [ EnumMembers!Sqrts ];
assert(sqrts == [ Sqrts.one, Sqrts.two, Sqrts.three ]);
--------------------

 A generic function $(D rank(v)) in the following example uses this
 template for finding a member $(D e) in an enumerated type $(D E).
--------------------
// Returns i if e is the i-th enumerator of E.
size_t rank(E)(E e)
    if (is(E == enum))
{
    foreach (i, member; EnumMembers!E)
    {
        if (e == member)
            return i;
    }
    assert(0, "Not an enum member");
}

enum Mode
{
    read  = 1,
    write = 2,
    map   = 4,
}
assert(rank(Mode.read ) == 0);
assert(rank(Mode.write) == 1);
assert(rank(Mode.map  ) == 2);
--------------------
 */
template EnumMembers(E)
    if (is(E == enum))
{
    // Supply the specified identifier to an constant value.
    template WithIdentifier(string ident)
    {
        static if (ident == "Symbolize")
        {
            template Symbolize(alias value)
            {
                enum Symbolize = value;
            }
        }
        else
        {
            mixin("template Symbolize(alias "~ ident ~")"
                 ~"{"
                     ~"alias "~ ident ~" Symbolize;"
                 ~"}");
        }
    }

    template EnumSpecificMembers(names...)
    {
        static if (names.length > 0)
        {
            alias TypeTuple!(
                    WithIdentifier!(names[0])
                        .Symbolize!(__traits(getMember, E, names[0])),
                    EnumSpecificMembers!(names[1 .. $])
                ) EnumSpecificMembers;
        }
        else
        {
            alias TypeTuple!() EnumSpecificMembers;
        }
    }

    alias EnumSpecificMembers!(__traits(allMembers, E)) EnumMembers;
}

/**
Returns the attributes attached to a function $(D func).

Example:
--------------------
alias FunctionAttribute FA; // shorten the enum name

real func(real x) pure nothrow @safe
{
    return x;
}
static assert(functionAttributes!func & FA.pure_);
static assert(functionAttributes!func & FA.safe);
static assert(!(functionAttributes!func & FA.trusted)); // not @trusted
--------------------
 */
enum FunctionAttribute : uint
{
    /**
     * These flags can be bitwise OR-ed together to represent complex attribute.
     */
    none     = 0,
    pure_    = 0b00000001, /// ditto
    nothrow_ = 0b00000010, /// ditto
    ref_     = 0b00000100, /// ditto
    property = 0b00001000, /// ditto
    trusted  = 0b00010000, /// ditto
    safe     = 0b00100000, /// ditto
}

/**
Returns a tuple consisting of the storage classes of the parameters of a
function $(D func).

Example:
--------------------
alias ParameterStorageClass STC; // shorten the enum name

void func(ref int ctx, out real result, real param)
{
}
alias ParameterStorageClassTuple!func pstc;
static assert(pstc.length == 3); // three parameters
static assert(pstc[0] == STC.ref_);
static assert(pstc[1] == STC.out_);
static assert(pstc[2] == STC.none);
--------------------
 */
enum ParameterStorageClass : uint
{
    /**
     * These flags can be bitwise OR-ed together to represent complex storage
     * class.
     */
    none   = 0,
    scope_ = 0b000_1,  /// ditto
    out_   = 0b001_0,  /// ditto
    ref_   = 0b010_0,  /// ditto
    lazy_  = 0b100_0,  /// ditto
}

/// ditto
template ParameterStorageClassTuple(func...)
    if (func.length == 1 && isCallable!func)
{
    alias Unqual!(FunctionTypeOf!func) Func;

    /*
     * TypeFuncion:
     *     CallConvention FuncAttrs Arguments ArgClose Type
     */
    alias ParameterTypeTuple!Func Params;

    // chop off CallConvention and FuncAttrs
    enum margs = demangleFunctionAttributes(mangledName!Func[1 .. $]).rest;

    // demangle Arguments and store parameter storage classes in a tuple
    template demangleNextParameter(string margs, size_t i = 0)
    {
        static if (i < Params.length)
        {
            enum demang = demangleParameterStorageClass(margs);
            enum skip = mangledName!(Params[i]).length; // for bypassing Type
            enum rest = demang.rest;

            alias TypeTuple!(
                    demang.value + 0, // workaround: "not evaluatable at ..."
                    demangleNextParameter!(rest[skip .. $], i + 1)
                ) demangleNextParameter;
        }
        else // went thru all the parameters
        {
            alias TypeTuple!() demangleNextParameter;
        }
    }

    alias demangleNextParameter!margs ParameterStorageClassTuple;
}

/**
Returns the mangled name of symbol or type $(D sth).

$(D mangledName) is the same as builtin $(D .mangleof) property, except that
the correct names of property functions are obtained.
--------------------
module test;

class C
{
    int value() @property;
}
pragma(msg, C.value.mangleof);      // prints "i"
pragma(msg, mangledName!(C.value)); // prints "_D4test1C5valueMFNdZi"
--------------------
 */
template mangledName(sth...)
    if (sth.length == 1)
{
    static if (is(typeof(sth[0]) X) && is(X == void))
    {
        // sth[0] is a template symbol
        enum string mangledName = removeDummyEnvelope(Dummy!sth.Hook.mangleof);
    }
    else
    {
        enum string mangledName = sth[0].mangleof;
    }
}

private template Dummy(T...) { struct Hook {} }

private string removeDummyEnvelope(string s)
{
    // remove --> S3std6traits ... Z4Hook
    s = s[12 .. $ - 6];

    // remove --> DIGIT+ __T5Dummy
    foreach (i, c; s)
    {
        if (c < '0' || '9' < c)
        {
            s = s[i .. $];
            break;
        }
    }
    s = s[9 .. $]; // __T5Dummy

    // remove --> T | V | S
    immutable kind = s[0];
    s = s[1 .. $];

    if (kind == 'S') // it's a symbol
    {
        /*
         * The mangled symbol name is packed in LName --> Number Name.  Here
         * we are chopping off the useless preceding Number, which is the
         * length of Name in decimal notation.
         *
         * NOTE: n = m + Log(m) + 1;  n = LName.length, m = Name.length.
         */
        immutable n = s.length;
        size_t m_upb = 10;

        foreach (k; 1 .. 5) // k = Log(m_upb)
        {
            if (n < m_upb + k + 1)
            {
                // Now m_upb/10 <= m < m_upb; hence k = Log(m) + 1.
                s = s[k .. $];
                break;
            }
            m_upb *= 10;
        }
    }

    return s;
}

struct Demangle(T)
{
    T       value;  // extracted information
    string  rest;
}

/* Demangles mstr as the storage class part of Argument. */
Demangle!uint demangleParameterStorageClass(string mstr)
{
    uint pstc = 0; // parameter storage class

    // Argument --> Argument2 | M Argument2
    if (mstr.length > 0 && mstr[0] == 'M')
    {
        pstc |= ParameterStorageClass.scope_;
        mstr  = mstr[1 .. $];
    }

    // Argument2 --> Type | J Type | K Type | L Type
    ParameterStorageClass stc2;

    switch (mstr.length ? mstr[0] : char.init)
    {
        case 'J': stc2 = ParameterStorageClass.out_;  break;
        case 'K': stc2 = ParameterStorageClass.ref_;  break;
        case 'L': stc2 = ParameterStorageClass.lazy_; break;
        default : break;
    }
    if (stc2 != ParameterStorageClass.init)
    {
        pstc |= stc2;
        mstr  = mstr[1 .. $];
    }

    return Demangle!uint(pstc, mstr);
}

/* Demangles mstr as FuncAttrs. */
Demangle!uint demangleFunctionAttributes(string mstr)
{
    enum LOOKUP_ATTRIBUTE =
    [
        'a': FunctionAttribute.pure_,
        'b': FunctionAttribute.nothrow_,
        'c': FunctionAttribute.ref_,
        'd': FunctionAttribute.property,
        'e': FunctionAttribute.trusted,
        'f': FunctionAttribute.safe
    ];
    uint atts = 0;

    // FuncAttrs --> FuncAttr | FuncAttr FuncAttrs
    // FuncAttr  --> empty | Na | Nb | Nc | Nd | Ne | Nf
    // except 'Ng' == inout, because it is a qualifier of function type
    while (mstr.length >= 2 && mstr[0] == 'N' && mstr[1] != 'g')
    {
        if (FunctionAttribute att = LOOKUP_ATTRIBUTE[ mstr[1] ])
        {
            atts |= att;
            mstr  = mstr[2 .. $];
        }
        else assert(0);
    }
    return Demangle!uint(atts, mstr);
}

alias TypeTuple!(byte, ubyte, short, ushort, int, uint, long, ulong) IntegralTypeList;
alias TypeTuple!(byte, short, int, long) SignedIntTypeList;
alias TypeTuple!(ubyte, ushort, uint, ulong) UnsignedIntTypeList;
alias TypeTuple!(float, double, real) FloatingPointTypeList;
alias TypeTuple!(ifloat, idouble, ireal) ImaginaryTypeList;
alias TypeTuple!(cfloat, cdouble, creal) ComplexTypeList;
alias TypeTuple!(IntegralTypeList, FloatingPointTypeList) NumericTypeList;
alias TypeTuple!(char, wchar, dchar) CharTypeList;

/// ditto
template functionAttributes(func...)
    if (func.length == 1 && isCallable!func)
{
    alias Unqual!(FunctionTypeOf!func) Func;

    enum uint functionAttributes =
            demangleFunctionAttributes(mangledName!Func[1 .. $]).value;
}

/**
Returns $(D true) if and only if $(D T)'s representation includes at
least one of the following: $(OL $(LI a raw pointer $(D U*);) $(LI an
array $(D U[]);) $(LI a reference to a class type $(D C).)
$(LI an associative array.) $(LI a delegate.))
 */
template hasIndirections(T)
{
    template Impl(T...)
    {
        static if (!T.length)
        {
            enum Impl = false;
        }
        else static if(isFunctionPointer!(T[0]))
        {
            enum Impl = Impl!(T[1 .. $]);
        }
        else static if(isStaticArray!(T[0]))
        {
            static if (is(T[0] _ : void[N], size_t N))
                enum Impl = true;
            else
                enum Impl = Impl!(T[1 .. $]) ||
                    Impl!(RepresentationTypeTuple!(typeof(T[0].init[0])));
        }
        else
        {
            enum Impl = isPointer!(T[0]) || isDynamicArray!(T[0]) ||
                is (T[0] : const(Object)) || isAssociativeArray!(T[0]) ||
                isDelegate!(T[0]) || is(T[0] == interface)
                || Impl!(T[1 .. $]);
        }
    }

    enum hasIndirections = Impl!(T, RepresentationTypeTuple!T);
}

/***
Get the primitive types of the fields of a struct or class, in
topological order.

Example:
----
struct S1 { int a; float b; }
struct S2 { char[] a; union { S1 b; S1 * c; } }
alias RepresentationTypeTuple!S2 R;
assert(R.length == 4
    && is(R[0] == char[]) && is(R[1] == int)
    && is(R[2] == float) && is(R[3] == S1*));
----
*/
template RepresentationTypeTuple(T)
{
    template Impl(T...)
    {
        static if (T.length == 0)
        {
            alias TypeTuple!() Impl;
        }
        else
        {
            static if (is(T[0] R: Rebindable!R))
            {
                alias Impl!(Impl!R, T[1 .. $]) Impl;
            }
            else  static if (is(T[0] == struct) || is(T[0] == union))
            {
    // @@@BUG@@@ this should work
    //             alias .RepresentationTypes!(T[0].tupleof)
    //                 RepresentationTypes;
                alias Impl!(FieldTypeTuple!(T[0]), T[1 .. $]) Impl;
            }
            else static if (is(T[0] U == typedef))
            {
                alias Impl!(FieldTypeTuple!U, T[1 .. $]) Impl;
            }
            else
            {
                alias TypeTuple!(T[0], Impl!(T[1 .. $])) Impl;
            }
        }
    }

    static if (is(T == struct) || is(T == union) || is(T == class))
    {
        alias Impl!(FieldTypeTuple!T) RepresentationTypeTuple;
    }
    else static if (is(T U == typedef))
    {
        alias RepresentationTypeTuple!U RepresentationTypeTuple;
    }
    else
    {
        alias Impl!T RepresentationTypeTuple;
    }
}

/*
 */
template AssocArrayTypeOf(T)
{
       immutable(V [K]) idx(K, V)(    immutable(V [K]) );

           inout(V)[K]  idy(K, V)(        inout(V)[K]  );
    shared(      V [K]) idy(K, V)( shared(      V [K]) );

           inout(V [K]) idz(K, V)(        inout(V [K]) );
    shared(inout V [K]) idz(K, V)( shared(inout V [K]) );

           inout(immutable(V)[K])  idw(K, V)(        inout(immutable(V)[K])  );
    shared(inout(immutable(V)[K])) idw(K, V)( shared(inout(immutable(V)[K])) );

    static if (is(typeof(idx(defaultInit!T)) X))
    {
        alias X AssocArrayTypeOf;
    }
    else static if (is(typeof(idy(defaultInit!T)) X))
    {
        alias X AssocArrayTypeOf;
    }
    else static if (is(typeof(idz(defaultInit!T)) X))
    {
               inout(             V  [K]) idzp(K, V)(        inout(             V  [K]) );
               inout(       const(V) [K]) idzp(K, V)(        inout(       const(V) [K]) );
               inout(shared(const V) [K]) idzp(K, V)(        inout(shared(const V) [K]) );
               inout(   immutable(V) [K]) idzp(K, V)(        inout(   immutable(V) [K]) );
        shared(inout              V  [K]) idzp(K, V)( shared(inout              V  [K]) );
        shared(inout        const(V) [K]) idzp(K, V)( shared(inout        const(V) [K]) );
        shared(inout    immutable(V) [K]) idzp(K, V)( shared(inout    immutable(V) [K]) );

        alias typeof(idzp(defaultInit!T)) AssocArrayTypeOf;
    }
    else static if (is(typeof(idw(defaultInit!T)) X))
        alias X AssocArrayTypeOf;
    else
        static assert(0, T.stringof~" is not an associative array type");
}

/**
$(D Rebindable!(T)) is a simple, efficient wrapper that behaves just
like an object of type $(D T), except that you can reassign it to
refer to another object. For completeness, $(D Rebindable!(T)) aliases
itself away to $(D T) if $(D T) is a non-const object type. However,
$(D Rebindable!(T)) does not compile if $(D T) is a non-class type.

Regular $(D const) object references cannot be reassigned:

----
class Widget { int x; int y() const { return x; } }
const a = new Widget;
a.y();          // fine
a.x = 5;        // error! can't modify const a
a = new Widget; // error! can't modify const a
----

However, $(D Rebindable!(Widget)) does allow reassignment, while
otherwise behaving exactly like a $(D const Widget):

----
auto a = Rebindable!(const Widget)(new Widget);
a.y();          // fine
a.x = 5;        // error! can't modify const a
a = new Widget; // fine
----

You may want to use $(D Rebindable) when you want to have mutable
storage referring to $(D const) objects, for example an array of
references that must be sorted in place. $(D Rebindable) does not
break the soundness of D's type system and does not incur any of the
risks usually associated with $(D cast).

 */
template Rebindable(T) if (is(T == class) || is(T == interface) || isArray!T)
{
    static if (!is(T X == const U, U) && !is(T X == immutable U, U))
    {
        alias T Rebindable;
    }
    else static if (isArray!T)
    {
        alias const(ElementType!T)[] Rebindable;
    }
    else
    {
        struct Rebindable
        {
            private union
            {
                T original;
                U stripped;
            }
            void opAssign(T another) pure nothrow
            {
                stripped = cast(U) another;
            }
            void opAssign(Rebindable another) pure nothrow
            {
                stripped = another.stripped;
            }
            static if (is(T == const U))
            {
                // safely assign immutable to const
                void opAssign(Rebindable!(immutable U) another) pure nothrow
                {
                    stripped = another.stripped;
                }
            }

            this(T initializer) pure nothrow
            {
                opAssign(initializer);
            }

            @property ref inout(T) get() inout pure nothrow
            {
                return original;
            }

            alias get this;
        }
    }
}

/**
 * Detect whether $(D T) is an associative array type
 */
template isAssociativeArray(T)
{
    enum bool isAssociativeArray = is(AssocArrayTypeOf!T) && !isAggregateType!T;
}

private import std.conv
    : emplace;

/**
Allocates a $(D class) object right inside the current scope,
therefore avoiding the overhead of $(D new). This facility is unsafe;
it is the responsibility of the user to not escape a reference to the
object outside the scope.

Note: it's illegal to move a class reference even if you are sure there
are no pointers to it. As such, it is illegal to move a scoped object.
 */
template scoped(T)
    if (is(T == class))
{
    // _d_newclass now use default GC alignment (looks like (void*).sizeof * 2 for
    // small objects). We will just use the maximum of filed alignments.
    alias classInstanceAlignment!T alignment;
    alias _alignUp!alignment aligned;

    static struct Scoped
    {
        // Addition of `alignment` is required as `Scoped_store` can be misaligned in memory.
        private void[aligned(__traits(classInstanceSize, T) + size_t.sizeof) + alignment] Scoped_store = void;

        @property inout(T) Scoped_payload() inout
        {
            void* alignedStore = cast(void*) aligned(cast(size_t) Scoped_store.ptr);
            // As `Scoped` can be unaligned moved in memory class instance should be moved accordingly.
            immutable size_t d = alignedStore - Scoped_store.ptr;
            size_t* currD = cast(size_t*) &Scoped_store[$ - size_t.sizeof];
            if(d != *currD)
            {
                import core.stdc.string;
                memmove(alignedStore, Scoped_store.ptr + *currD, __traits(classInstanceSize, T));
                *currD = d;
            }
            return cast(inout(T)) alignedStore;
        }
        alias Scoped_payload this;

        @disable this();
        @disable this(this);

        ~this()
        {
            // `destroy` will also write .init but we have no functions in druntime
            // for deterministic finalization and memory releasing for now.
            .destroy(Scoped_payload);
        }
    }

    /// Returns the scoped object
    @system auto scoped(Args...)(auto ref Args args)
    {
        Scoped result = void;
        void* alignedStore = cast(void*) aligned(cast(size_t) result.Scoped_store.ptr);
        immutable size_t d = alignedStore - result.Scoped_store.ptr;
        *cast(size_t*) &result.Scoped_store[$ - size_t.sizeof] = d;
        emplace!(Unqual!T)(result.Scoped_store[d .. $ - size_t.sizeof], args);
        return result;
    }
}

/**
Returns class instance alignment.

Example:
---
class A { byte b; }
class B { long l; }

// As class instance always has a hidden pointer
static assert(classInstanceAlignment!A == (void*).alignof);
static assert(classInstanceAlignment!B == long.alignof);
---
 */
template classInstanceAlignment(T) if(is(T == class))
{
    alias maxAlignment!(void*, typeof(T.tupleof)) classInstanceAlignment;
}

private template maxAlignment(U...) if(isTypeTuple!U)
{
    static if(U.length == 1)
        enum maxAlignment = U[0].alignof;
    else
        enum maxAlignment = max(U[0].alignof, .maxAlignment!(U[1 .. $]));
}

/**
Detect whether tuple $(D T) is a type tuple.
 */
template isTypeTuple(T...)
{
    static if (T.length >= 2)
        enum bool isTypeTuple = isTypeTuple!(T[0 .. $/2]) && isTypeTuple!(T[$/2 .. $]);
    else static if (T.length == 1)
        enum bool isTypeTuple = is(T[0]);
    else
        enum bool isTypeTuple = true; // default
}

private size_t _alignUp(size_t alignment)(size_t n)
    if(alignment > 0 && !((alignment - 1) & alignment))
{
    enum badEnd = alignment - 1; // 0b11, 0b111, ...
    return (n + badEnd) & ~badEnd;
}

/**
 * Creates a typetuple out of a sequence of zero or more types.
 */
template TypeTuple(TList...)
{
    alias TList TypeTuple;
}

public import std.variant
    : Variant;

version (Windows)
{
    public import std.windows.charset
        : fromMBSz;
}

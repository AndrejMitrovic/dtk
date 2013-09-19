/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.utils;

import std.array;
static import std.conv;
import std.algorithm;
import std.functional;
import std.stdio;
static import std.string;
import std.traits;

import dtk.loader;

package alias translate = std.string.translate;
package alias chomp = std.string.chomp;
package alias chompPrefix = std.string.chompPrefix;
package alias lastIndexOf = std.string.lastIndexOf;

 //~ to!int(value);

private template isRawStaticArray(T, A...)
{
    enum isRawStaticArray =
        A.length == 0 &&
        isStaticArray!T &&
        !is(T == class) &&
        !is(T == interface) &&
        !is(T == struct) &&
        !is(T == union);
}

public alias text = std.conv.text;
public alias ConvException = std.conv.ConvException;

/** Workaround for bad exception file and line info. */
template to(T)
{
    T to(string file = __FILE__, size_t line = __LINE__, A...)(A input)
        if (!isRawStaticArray!A)
    {
        try
        {
            return std.conv.to!T(input);
        }
        catch (std.conv.ConvException ex)
        {
            ex.file = file;
            ex.line = line;
            throw ex;
        }
    }

    // Issue 6175
    T to(S)(ref S input, string file = __FILE__, size_t line = __LINE__)
        if (isRawStaticArray!S)
    {
        try
        {
            return std.conv.to!T(input);
        }
        catch (std.conv.ConvException ex)
        {
            ex.file = file;
            ex.line = line;
            throw ex;
        }
    }
}

/** Wrapper around format which sets the file and line of any exception to the call site. */
string format(string file = __FILE__, size_t line = __LINE__, Args...)(string fmtStr, Args args)
{
    static import std.string;

    try
    {
        return std.string.format(fmtStr, args);
    }
    catch (Exception exc)
    {
        exc.file = file;
        exc.line = line;
        throw exc;
    }
}

/** Convert a Tcl string value into a D type. */
T tclConv(T)(const(char)* input)
{
    auto res = to!string(input);
    if (res == "??")  // note: edge-case, but there might be more of them
        return T.init;

    return to!T(res);
}

/**
    Extract aggregate or enum $(D T)'s members by making aliases to each member,
    effectively making the members accessible from module scope without qualifications.
*/
package mixin template ExportMembers(T)
{
    mixin(_makeAggregateAliases!(T)());
}

package string _makeAggregateAliases(T)()
{
    enum enumName = __traits(identifier, T);
    string[] result;

    foreach (string member; __traits(allMembers, T))
        result ~= format("alias %s = %s.%s;", member, enumName, member);

    return result.join("\n");
}

/** Return an escaped Tcl string literal which can be used in Tcl commands. */
string _tclEscape(T)(T input)
{
    // todo: use a buffer once Issue 10868 is implemented:
    // http://d.puremagic.com/issues/show_bug.cgi?id=10868

    // note: have to use to!string because there is a lot of implicit conversions in D:
    // char -> int
    // dchar and int can't be overloaded
    // enum -> int
    return format(`"%s"`, to!string(input).translate(_tclTransTable));
}

/// similar to OriginalType, but without the modifier stripping
package template EnumBaseType(E) if (is(E == enum))
{
    static if (is(E B == enum))
        alias EnumBaseType = B;
}

/// frequent typo
alias BaseEnumType = EnumBaseType;

unittest
{
    enum EI : int { x = 0 }
    enum EF : float { x = 1.5 }
    static assert(is(BaseEnumType!EI == int));
    static assert(is(BaseEnumType!EF == float));
}

/// required due to Issue 10814 - Formatting string-based enum prints its name instead of its value
package EnumBaseType!E toBaseType(E)(E val)
{
    return cast(typeof(return))val;
}

/** Return the slice of a null-terminated C string, without allocating a new string. */
inout(char)[] peekCString(inout(char)* s)
{
    if (s is null)
        return null;

    inout(char)* ptr;
    for (ptr = s; *ptr; ++ptr) { }

    return s[0 .. ptr - s];
}

///
unittest
{
    const(char)[] input = "foo\0";
    assert(peekCString(input.ptr).ptr == input.ptr);
}

/**
    Generate a toString() method for an aggregate type.
    Issue 9872: format should include class field values.
*/
mixin template gen_toString()
{
    override string toString()
    {
        Appender!(string[]) result;

        foreach (val; this.tupleof)
            result ~= to!string(val);

        return format("%s(%s)", __traits(identifier, typeof(this)), join(result.data, ", "));
    }
}

/+ ///
unittest
{
    static class C
    {
        this(int x, int y)
        {
            this.x = x;
            this.y = y;
        }

        mixin gen_toString;

        int x;
        int y;
    }

    auto c = new C(1, 2);
    assert(text(c) == "C(1, 2)");
} +/

/** Static cast. */
T StaticCast(T, S)(S source)
{
    return cast(T)(*cast(void**)&source);
}

///
unittest
{
    class A { int x; }
    class B : A { int y; this(int y) { this.y = y; } }

    A a = new B(1);
    B b = StaticCast!B(a);
    assert(b.y == 1);

    import std.typecons;

    auto sb = scoped!B(2);
    A as = sb;
    B bs = StaticCast!B(as);
    assert(bs.y == 2);
}

/**
    Checks whether $(D Target) matches any $(D Types).
*/
template isOneOf(Target, Types...)
{
    static if (Types.length > 1)
    {
        enum bool isOneOf = isOneOf!(Target, Types[0]) || isOneOf!(Target, Types[1 .. $]);
    }
    else static if (Types.length == 1)
    {
        enum bool isOneOf = is(Unqual!Target == Unqual!(Types[0]));
    }
    else
    {
        enum bool isOneOf = false;
    }
}

///
unittest
{
    static assert(isOneOf!(int, float, string, const(int)));
    static assert(isOneOf!(const(int), float, string, int));
    static assert(!isOneOf!(int, float, string));
}

/** Strip off the qualifiers of an object's dynamic class name. */
string getClassName(inout(Object) object)
{
    string qualClassName = typeid(object).name;
    return qualClassName[qualClassName.lastIndexOf(".") + 1 .. $];
}

/**
    Return string representation of argument.
    If argument is already a string or a
    character, enquote it to make it more readable.
*/
string enquote(T)(T arg)
{
    import std.range : isInputRange, ElementEncodingType;

    static if (isSomeString!T)
        return format(`"%s"`, arg);
    else
    static if (isSomeChar!T)
        return format("'%s'", arg);
    else
    static if (isInputRange!T && is(ElementEncodingType!T == dchar))
        return format(`"%s"`, to!string(arg));
    else
        return to!string(arg);
}

unittest
{
    assert(enquote(0) == "0");
    assert(enquote(enquote(0)) == `"0"`);
    assert(enquote("foo") == `"foo"`);
    assert(enquote('a') == "'a'");

    auto r = ["foo", "bar"].joiner("_");
    assert(enquote(r) == `"foo_bar"`);
}

/**
    Return the element type of Type.

    Note: This is different from ElementType in
    std.range which returns the type of the .front property.
*/
template ElementTypeOf(Type)
{
    static if(is(Type T : T[N], size_t N))
    {
        alias ElementTypeOf = T;
    }
    else
    static if(is(Type T : T[]))
    {
        alias ElementTypeOf = T;
    }
    else
    static if(is(Type T : T*))
    {
        alias ElementTypeOf = T;
    }
    else
    {
        alias ElementTypeOf = Type;
    }
}

///
unittest
{
    static assert(is(ElementTypeOf!int == int));
    static assert(is(ElementTypeOf!(int[]) == int));
    static assert(is(ElementTypeOf!(int[][]) == int[]));
    static assert(is(ElementTypeOf!(int[1][2]) == int[1]));
    static assert(is(ElementTypeOf!(int**) == int*));
}

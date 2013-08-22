/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.utils;

import std.array;
import std.conv;
import std.algorithm;
import std.functional;
import std.stdio;
import std.string;
import std.traits;

import dtk.loader;

alias spaceJoin = pipe!(map!(to!string), reduce!("a ~ ' ' ~ b"));

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

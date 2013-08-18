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

package string _enquote(T)(T option)
{
    return format(`"%s"`, option);
}

// Couldn't find Tcl equivalent of raw strings, need to escape backslashes
package string _escapePath(string input)
{
    return input.replace(r"\", r"\\");
}

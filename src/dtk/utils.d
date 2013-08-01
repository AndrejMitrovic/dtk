/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.utils;

import std.conv;
import std.algorithm;
import std.functional;
import std.stdio;
import std.string;

alias spaceJoin = pipe!(map!(to!string), reduce!("a ~ ' ' ~ b"));

auto safeToInt(T)(T* val)
{
    auto res = to!string(val);
    if (res == "??")  // note: edge-case, but there might be more of them
        return 0;    // note2: "0" is just a guess, not sure what else to set it to.

    return to!int(res);
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

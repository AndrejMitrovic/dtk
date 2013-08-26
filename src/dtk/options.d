/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.options;

import std.array;
import std.string;

/** Convenience. */
alias DtkOptions = string[string];

string options2string(DtkOptions opts)
{
    Appender!(string[]) result;

    foreach (key, val; opts)
        result ~= format(`-%s "%s"`, key, val);

    return result.data.join(" ");
}

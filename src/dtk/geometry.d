/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.geometry;

import std.algorithm;
import std.conv;
import std.string;

///
struct Point
{
    int x;
    int y;
}

///
struct Size
{
    int width;
    int height;
}

///
struct Rect
{
    int x;
    int y;
    int width;
    int height;
}

///
struct Padding
{
    int left = 0;
    int top = 0;
    int right = 0;
    int bottom = 0;
}

package string toString(Padding padding)
{
    return format("%s %s %s %s", padding.left, padding.top, padding.right, padding.bottom);
}

package Padding toPadding(string input)
{
    Padding result;

    size_t idx;

    // nogo
    /+ foreach (value; input.splitter())
        result.tupleof[idx++] = to!int(value); +/

    auto values = input.splitter();
    if (values.empty)
        return result;

    result.left = to!int(values.front);

    values.popFront();
    if (values.empty)
        return result;

    result.top = to!int(values.front);

    values.popFront();
    if (values.empty)
        return result;

    result.right = to!int(values.front);

    values.popFront();
    if (values.empty)
        return result;

    result.bottom = to!int(values.front);

    return result;
}

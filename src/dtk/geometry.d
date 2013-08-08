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

    // .tupleof won't work due to idx being a runtime value
    foreach (value; input.splitter())
        (*(cast(int[4]*)&result))[idx++] = to!int(value);

    return result;
}

///
unittest
{
    Padding padding;

    padding = Padding(10);
    assert(padding.toString.toPadding == Padding(10));

    padding = Padding(10, 20);
    assert(padding.toString.toPadding == Padding(10, 20));

    padding = Padding(10, 20, 30);
    assert(padding.toString.toPadding == Padding(10, 20, 30));

    padding = Padding(10, 20, 30, 40);
    assert(padding.toString.toPadding == Padding(10, 20, 30, 40));

    padding = Padding(0, 0, 0, 10);
    assert(padding.toString.toPadding == Padding(0, 0, 0, 10));

    padding = Padding(0, 0, 10, 20);
    assert(padding.toString.toPadding == Padding(0, 0, 10, 20));

    padding = Padding(0, 10, 20, 30);
    assert(padding.toString.toPadding == Padding(0, 10, 20, 30));

    padding = Padding(10, 20, 30, 40);
    assert(padding.toString.toPadding == Padding(10, 20, 30, 40));
}

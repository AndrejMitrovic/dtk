/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.geometry;

import core.exception;

import std.algorithm;
import std.conv;
import std.exception;
import std.string;
import std.traits;
import std.typetuple;

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

    static assert(is(FieldTypeTuple!(typeof(result)) == TypeTuple!(int, int, int, int)));
    static assert(typeof(result).sizeof == (int[4]).sizeof);

    // .tupleof won't work due to idx being a runtime value
    foreach (value; input.splitter())
    {
        assert(idx < FieldTypeTuple!(typeof(result)).length);

        (*(cast(int[4]*)&result))[idx++] = to!int(value);
    }

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

    assertThrown!AssertError("10 20 30 40 50".toPadding);
}

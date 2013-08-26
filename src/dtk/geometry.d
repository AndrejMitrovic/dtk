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

string toString(Padding padding)
{
    return format("%s %s %s %s", padding.left, padding.top, padding.right, padding.bottom);
}

Padding toPadding(string input)
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

///
enum Sticky
{
    none,
    n,
    ns,
    nse,
    nsew,
}

Sticky toSticky(string sticky)
{
    switch (sticky) with (Sticky)
    {
        case "":            return none;
        case "n":           return n;
        case "ns":          return ns;
        case "nse":         return nse;
        case "nsew":        return nsew;
        default:            assert(0, format("Unhandled sticky: '%s'", sticky));
    }
}

///
enum Anchor
{
    invalid,  // sentinel

    none,       ///
    north,      ///
    northEast,  ///
    east,       ///
    southEast,  ///
    south,      ///
    southWest,  ///
    west,       ///
    northWest,  ///
    center,     ///
}

Anchor toAnchor(string anchor)
{
    switch (anchor) with (Anchor)
    {
        case "":            return none;
        case "n":           return north;
        case "ne":          return northEast;
        case "e":           return east;
        case "se":          return southEast;
        case "s":           return south;
        case "sw":          return southWest;
        case "w":           return west;
        case "nw":          return northWest;
        case "center":      return center;
        default:            assert(0, format("Unhandled anchor: '%s'", anchor));
    }
}

string toString(Anchor anchor)
{
    final switch (anchor) with (Anchor)
    {
        case none:          return "";
        case north:         return "n";
        case northEast:     return "ne";
        case east:          return "e";
        case southEast:     return "se";
        case south:         return "s";
        case southWest:     return "sw";
        case west:          return "w";
        case northWest:     return "nw";
        case center:        return "center";
        case invalid:       assert(0, format("Uninitialized anchor: '%s'", anchor));
    }
}

///
enum BorderStyle
{
    invalid,  // sentinel

    flat,   ///
    groove, ///
    raised, ///
    ridge,  ///
    solid,  ///
    sunken, ///
}

/// If there are multiple lines of text, specifies how the lines are laid out relative to one another.
enum Justification
{
    invalid,  // sentinel

    none,   ///
    left,   ///
    center, ///
    right,  ///
}

Justification toJustification(string justification)
{
    switch (justification) with (Justification)
    {
        case "":        return none;
        case "left":    return left;
        case "center":  return center;
        case "right":   return right;
        default:        assert(0, format("Unhandled justification: '%s'", justification));
    }
}

string toString(Justification justification)
{
    final switch (justification) with (Justification)
    {
        case none:          return "";
        case left:          return "left";
        case center:        return "center";
        case right:         return "right";
        case invalid:       assert(0, format("Uninitialized justification: '%s'", justification));
    }
}

///
enum Orientation
{
    horizontal,  ///
    vertical     ///
}

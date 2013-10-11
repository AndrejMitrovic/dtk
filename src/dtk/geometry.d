/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.geometry;

import core.exception;

import std.algorithm;
import std.exception;
import std.traits;
import std.typetuple;

import dtk.utils;

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

private bool _isStickyString(string sticky)
{
    char[4] elems = ['n', 's', 'e', 'w'];

    return all!(a => elems[].canFind(a))(sticky)
           && sticky.count('n') <= 1
           && sticky.count('s') <= 1
           && sticky.count('e') <= 1
           && sticky.count('w') <= 1;
}

/**
    Marks which sides a widget should stick to.

    Sticky.n will jam the widget up against the top side,
    with any extra vertical space on the bottom;
    the widget will still be centered horizontally.

    Sticky.nw (north-west) means the widget will be stuck to the
    top left corner, with extra space on the bottom and right.

    Specifying two opposite edges, such as Sticky.we (west, east)
    means that the widget will be stretched, in this case so it is
    stuck both to the left and right edge. So the widget will then be
    wider than its "ideal" size. Most widgets have options that can
    control how they are displayed if they are larger than needed.

    For example, a label widget has an "anchor" option which
    controls where the text of the label will be positioned.
*/
struct Sticky
{
    @disable this();

    /**
        E.g. use:
        -----
        auto sticky = Sticky.nsew;
        -----
    */
    static Sticky opDispatch(string sticky)()
    {
        static assert(sticky.length <= 4, "Can only list 4 sides.");
        static assert(sticky._isStickyString, "All sticky options must be one of nsew");
        return Sticky(sticky);
    }

    package this(string sticky)
    {
        _sticky = sticky;
    }

    string toString() const
    {
        return _sticky;
    }

    bool opEquals(const(Sticky) rhs) const
    {
        if (_sticky.length != rhs._sticky.length)
            return false;

        foreach (ch; _sticky)
        {
            if (!rhs._sticky.canFind(ch))
                return false;
        }

        return true;
    }

private:
    const(string) _sticky;
}

unittest
{
    // too many chars
    static assert(!__traits(compiles, Sticky.nnsew));

    // non-existent chars
    static assert(!__traits(compiles, Sticky.asdf));

    // duplicate chars
    static assert(!__traits(compiles, Sticky.nnnn));

    static assert(__traits(compiles, Sticky.n));
    static assert(__traits(compiles, Sticky.ns));
    static assert(__traits(compiles, Sticky.nse));
    static assert(__traits(compiles, Sticky.nsew));

    assert(Sticky.ns == Sticky.ns);
    assert(Sticky.ns == Sticky.sn);
    assert(Sticky.sn == Sticky.ns);
    assert(Sticky.nsew == Sticky.wesn);
    assert(Sticky.ns != Sticky.ne);
    assert(Sticky.ns != Sticky.nsew);
}

///
enum Anchor
{
    invalid, /// sentinel
    none,    ///
    n,       ///
    ne,      ///
    e,       ///
    se,      ///
    s,       ///
    sw,      ///
    w,       ///
    nw,      ///
    center,  ///
}

Anchor toAnchor(string anchor)
{
    switch (anchor) with (Anchor)
    {
        case "":        return none;
        case "n":       return n;
        case "ne":      return ne;
        case "e":       return e;
        case "se":      return se;
        case "s":       return s;
        case "sw":      return sw;
        case "w":       return w;
        case "nw":      return nw;
        case "center":  return center;
        default:        assert(0, format("Unhandled anchor: '%s'", anchor));
    }
}

string toString(Anchor anchor)
{
    final switch (anchor) with (Anchor)
    {
        case none:     return "";
        case n:        return "n";
        case ne:       return "ne";
        case e:        return "e";
        case se:       return "se";
        case s:        return "s";
        case sw:       return "sw";
        case w:        return "w";
        case nw:       return "nw";
        case center:   return "center";
        case invalid:  assert(0, format("Uninitialized anchor: '%s'", anchor));
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
enum Angle
{
    horizontal,  ///
    vertical     ///
}

/** Phobos parse functions can't use a custom delimiter. */
package Rect toGeometry(string input)
{
    typeof(return) result;

    sizediff_t xOffset = input.countUntil("x");
    sizediff_t firstPlus = input.countUntil("+");
    sizediff_t secondPlus = input.countUntil("+") + 1 + input[input.countUntil("+") + 1 .. $].countUntil("+");

    string width = input[0 .. xOffset];
    string height = input[xOffset + 1 .. firstPlus];

    string x = input[firstPlus + 1 .. secondPlus];
    string y = input[secondPlus + 1 .. $];

    result.x = to!int(x);
    result.y = to!int(y);
    result.width = to!int(width);
    result.height = to!int(height);

    return result;
}

///
unittest
{
    assert("200x200+88+-88".toGeometry == Rect(88, -88, 200, 200));
    assert("200x200+-88+88".toGeometry == Rect(-88, 88, 200, 200));
    assert("200x200+88+88".toGeometry == Rect(88, 88, 200, 200));
}

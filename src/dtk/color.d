/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.color;

import dtk.imports;
import dtk.utils;

///
struct RGB
{
    ubyte r;
    ubyte g;
    ubyte b;

    string toString()
    {
        return format("#%02X%02X%02X", this.r, this.g, this.b);
    }
}

RGB toRGB(string input)
{
    if (input.empty)
        return RGB.init;

    enforce(input.startsWith("#"));
    input.popFront();

    RGB res;

    foreach (ref field; res.tupleof)
    {
        field = to!ubyte(input[0 .. 2], 16);
        input.popFrontN(2);
    }

    return res;
}

///
unittest
{
    assert("".toRGB == RGB(0, 0, 0));
    assert(RGB(10, 20, 30).toString() == "#0A141E");
    assert(RGB(10, 20, 30).toString().toRGB == RGB(10, 20, 30));
}

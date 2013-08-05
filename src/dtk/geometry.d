/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.geometry;

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

/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.event;

struct Event
{
    int x;
    int y;
    int keycode;
    int character;
    int width;
    int height;
    int root_x;
    int root_y;
}

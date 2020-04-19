/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.cursor;

import dtk.utils;

import std.conv;
import std.range;

/** The list of cursors. */
enum Cursor
{
    inherited,  /// inherited from the parent widget
    X_cursor,
    arrow,
    based_arrow_down,
    based_arrow_up,
    boat,
    bogosity,
    bottom_left_corner,
    bottom_right_corner,
    bottom_side,
    bottom_tee,
    box_spiral,
    center_ptr,
    circle,
    clock,
    coffee_mug,
    cross,
    cross_reverse,
    crosshair,
    diamond_cross,
    dot,
    dotbox,
    double_arrow,
    draft_large,
    draft_small,
    draped_box,
    exchange,
    fleur,
    gobbler,
    gumby,
    hand1,
    hand2,
    heart,
    icon,
    iron_cross,
    left_ptr,
    left_side,
    left_tee,
    leftbutton,
    ll_angle,
    lr_angle,
    man,
    middlebutton,
    mouse,
    none,
    pencil,
    pirate,
    plus,
    question_arrow,
    right_ptr,
    right_side,
    right_tee,
    rightbutton,
    rtl_logo,
    sailboat,
    sb_down_arrow,
    sb_h_double_arrow,
    sb_left_arrow,
    sb_right_arrow,
    sb_up_arrow,
    sb_v_double_arrow,
    shuttle,
    sizing,
    spider,
    spraycan,
    star,
    target,
    tcross,
    top_left_arrow,
    top_left_corner,
    top_right_corner,
    top_side,
    top_tee,
    trek,
    ul_angle,
    umbrella,
    ur_angle,
    watch,
    xterm,
}

package Cursor toCursor(string input)
{
    if (input.empty)
        return Cursor.inherited;

    return to!Cursor(input);
}

package string toTclString(Cursor cursor)
{
    if (cursor == Cursor.inherited)
        return "";

    return to!string(cursor);
}

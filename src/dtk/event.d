/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.event;

import std.string;

import dtk.geometry;
import dtk.utils;

/** All possible Dtk events. */
enum EventType
{
    Invalid,  // sentinel
    Activate,
    Destroy,
    Map,
    ButtonPress,
    // Button,
    Enter,
    MapRequest,
    ButtonRelease,
    Expose,
    Motion,
    Circulate,
    FocusIn,
    MouseWheel,
    CirculateRequest,
    FocusOut,
    Property,
    Colormap,
    Gravity,
    Reparent,
    Configure,
    KeyPress,
    Key,
    ResizeRequest,
    ConfigureRequest,
    KeyRelease,
    Unmap,
    Create,
    Leave,
    Visibility,
    Deactivate,

    TkButtonPush,
}

struct Event
{
    EventType type;

    int x;
    int y;
    int keycode;
    int character;
    int width;
    int height;
    int root_x;
    int root_y;
}

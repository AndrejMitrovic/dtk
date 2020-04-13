/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.tests.cairo.test_cairo;


import cairo.cairo;
import cairo.win32;

import core.runtime;
import std.utf;

pragma(lib, "gdi32.lib");
import win32.windef;
import win32.winuser;
import win32.wingdi;

import core.thread;

import std.conv;
import std.exception;
import std.range;
import std.stdio;
import std.string;

import dtk;

void main()
{
    auto app = new App;
    app.mainWindow.size = dtk.Size(200, 200);

    auto frame = new Frame(app.mainWindow);
    frame.pack();

    // fetch the hex ID of the HWND
    //~ string hex = tclEvalFmt("winfo id %s", app.mainWindow.getTclName());

    // convert it to a HWND type
    //~ HWND hwnd = cast(HWND)to!long(hex[2..$], 16);

    auto hwnd = getHWND(app.mainWindow);

    auto hdc = GetDC(hwnd);
    assert(hdc);  // verify the call worked

    RECT rc;
    GetClientRect(hwnd, &rc);  // grab the size
    HANDLE hBrush = CreateSolidBrush(win32.wingdi.RGB(255, 0, 0));

    // fill the entire window red
    FillRect(hdc, &rc, hBrush);
    ReleaseDC(hwnd, hdc);
    DeleteObject(hBrush);

    DestroyWindow(hwnd);

    // note: window is only painted when destroyed
    //~ DestroyWindow(hwnd);

    //~ stderr.writeln("DC: ", hdc);
    //~ scope(exit) ReleaseDC(hwnd, hdc);

    //~ auto _buffer    = CreateCompatibleDC(hdc);
    //~ auto hBitmap    = CreateCompatibleBitmap(hdc, 200, 200);
    //~ auto hOldBitmap = SelectObject(_buffer, hBitmap);

    //~ auto surf = new Win32Surface(_buffer);
    //~ auto ctx = Context(surf);

    //~ ctx.setSourceRGB(0, 1, 1);
    //~ ctx.paint();

    //~ surf.finish();
    //~ BitBlt(hdc, 0, 0, 200, 200, _buffer, 0, 0, SRCCOPY);

    //~ SelectObject(_buffer, hOldBitmap);
    //~ DeleteObject(hBitmap);
    //~ DeleteDC(_buffer);

    //~ ReleaseDC(hwnd, hdc);

    app.run();
}

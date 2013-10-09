/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.tests.test_events_focus;

version(unittest):
version(DTK_UNITTEST):

import std.conv;
import std.string;

import dtk;

import dtk.tests.globals;

/**
    Windows-only for now, since we need to use WinAPI to send Tab keys.
    Tk can't generate proper tab key events which we need to cause focus
    changes. However since the focus code in DTK is not platform-specific
    then running the test-suite on Windows only is fine.
*/
version(Windows):

import dtk.platform.win32.defs;

extern (Windows) LRESULT SendMessageW(HWND, UINT, WPARAM, LPARAM);
const WM_KEYDOWN=256;
const VK_TAB = 0x09;
const WM_KEYUP=257;

unittest
{
    auto testWindow = new Window(app.mainWindow, 200, 200);

    Button[] buttons;

    size_t idx;
    foreach (row; 0 .. 2)
    foreach (col; 0 .. 2)
    {
        auto button = new Button(testWindow, format("Button %s", idx++));
        button.grid.setRow(row).setCol(col);
        buttons ~= button;
    }

    testWindow.focus();

    auto hwnd = getWinHandle(testWindow);

    void pressTab()
    {
        SendMessageW(hwnd, WM_KEYDOWN, VK_TAB, 0);
        SendMessageW(hwnd, WM_KEYUP, VK_TAB, 0);
    }

    size_t callCount;
    size_t expectedCallCount;

    testWindow.onKeyboardEvent ~= (scope KeyboardEvent ev)
    {
        if (ev.keySym != KeySym.Tab)
        {
            pressTab();
            pressTab();
            pressTab();
            pressTab();
            pressTab();
        }
    };

    size_t reqCount;
    size_t focusCount;

    testWindow.onSinkEvent ~= (scope Event ev)
    {
        callCount++;

        if (ev.type != EventType.focus)
            return;

        auto event = cast(FocusEvent)ev;
        //~ stderr.writefln("Focus event %s", event);

        if (event.action == FocusAction.request)
        {
            switch (reqCount)
            {
                case 0: event.allowFocus = true; break;
                case 1: event.allowFocus = false; break;
                case 2: event.widget.allowFocus = false; break;
                default:
            }

            reqCount++;
        }

        if (event.action == FocusAction.focus)
        {
            Widget widget;

            switch (focusCount)
            {
                case 0: widget = buttons[0]; break;
                case 1: widget = buttons[3]; break;
                case 2: widget = buttons[0]; break;
                case 3: widget = buttons[1]; break;
                case 4: widget = buttons[3]; break;
                default:
            }

            //~ stderr.writefln("Focused: %s %s", focusCount, event.widget);
            assert(event.widget is widget, text(event.widget, " != ", widget));
            focusCount++;
        }
    };

    // set up a timer so it's fired up only after the event loop is running
    tclEvalFmt("after 1 { event generate %s <KeyPress> -keysym %s }", testWindow.getTclName(), 'a');

    app.testRun();

    // this is just an approximation, what's important is that the asserts are actually invoked.
    expectedCallCount = 30;
    assert(callCount >= expectedCallCount, text(callCount, " ! >= ", expectedCallCount));
}

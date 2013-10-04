/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.tests.test_events_keyboard;

version(unittest):
version(DTK_UNITTEST):

import core.thread;

import std.algorithm;
import std.conv;
import std.range;
import std.stdio;
import std.traits;
import std.typetuple;

import dtk;

import dtk.tests.globals;

unittest
{
    auto testWindow = new Window(app.mainWindow, 200, 200);

    KeyboardAction action;
    KeySym keySym;
    dchar unichar;
    KeyMod keyMod;

    // we only want to test this when we explicitly generate move events,
    // since the mouse can be at an arbitrary point when generating non-move events.
    bool motionTest;
    Point widgetMousePos;

    size_t callCount;
    size_t expectedCallCount;

    // when modifier keys like control are present we really don't know which uni chars will be generated.
    bool checkUnichar;

    auto handler = (scope KeyboardEvent e)
    {
        //~ stderr.writefln(" keyboard: %s", e);

        assert(e.action == action, text(e.action,  " != ", action));
        assert(e.keySym == keySym, text(e.keySym,  " != ", keySym));

        if (checkUnichar)
            assert(e.unichar == unichar, text(e.unichar, " != ", unichar));

        assert(e.keyMod == keyMod, text(e.keyMod,  " != ", keyMod));

        if (motionTest)
            assert(e.widgetMousePos == widgetMousePos, text(e.widgetMousePos, " ", widgetMousePos));

        ++callCount;
    };

    testWindow.onKeyboardEvent ~= handler;

    // note: you can only send key events to the focused window.
    testWindow.focus();

    // workaround for missing enum
    static immutable keySyms = [
        KeySym.a, KeySym.b, KeySym.c, KeySym.d, KeySym.e, KeySym.f, KeySym.g,
        KeySym.h, KeySym.i, KeySym.j, KeySym.k, KeySym.l, KeySym.m, KeySym.n,
        KeySym.o, KeySym.p, KeySym.q, KeySym.r, KeySym.s, KeySym.t, KeySym.u,
        KeySym.v, KeySym.w, KeySym.x, KeySym.y, KeySym.z,

        KeySym.A, KeySym.B, KeySym.C, KeySym.D, KeySym.E, KeySym.F, KeySym.G,
        KeySym.H, KeySym.I, KeySym.J, KeySym.K, KeySym.L, KeySym.M, KeySym.N,
        KeySym.O, KeySym.P, KeySym.Q, KeySym.R, KeySym.S, KeySym.T, KeySym.U,
        KeySym.V, KeySym.W, KeySym.X, KeySym.Y, KeySym.Z,
    ];

    alias keyMods = KeyMod.allKeyMods;

    foreach (dchar newChar; 'a' .. 'z' + 1)
    {
        keyMod = KeyMod.none;
        motionTest = false;
        action = KeyboardAction.press;
        unichar = newChar;
        keySym = keySyms[newChar - 'a'];
        checkUnichar = true;
        tclEvalFmt("event generate %s <KeyPress> -keysym %s", testWindow.getTclName(), newChar);
        ++expectedCallCount;

        action = KeyboardAction.release;
        tclEvalFmt("event generate %s <KeyRelease> -keysym %s", testWindow.getTclName(), newChar);
        ++expectedCallCount;

        // test mouse move
        foreach (x; 0 .. 5)
        foreach (y; 5 .. 10)
        {
            action = KeyboardAction.press;
            motionTest = true;
            widgetMousePos = Point(x, y);
            tclEvalFmt("event generate %s <KeyPress> -keysym %s -x %s -y %s",
                        testWindow.getTclName(), newChar, widgetMousePos.x, widgetMousePos.y);
            ++expectedCallCount;
        }

        // test with key modifiers
        checkUnichar = false;
        motionTest = false;
        foreach (newKeyMod; keyMods)
        {
            keyMod = newKeyMod;

            if (newKeyMod.isAnyDown(KeyMod.shift, KeyMod.capslock))
                keySym = keySyms[(newChar - 'a') + (keySyms.length / 2)];  // uppercase it
            else
                keySym = keySyms[newChar - 'a'];

            action = KeyboardAction.press;
            tclEvalFmt("event generate %s <KeyPress> -keysym %s -state %s", testWindow.getTclName(), newChar, newKeyMod.toTclValue);
            ++expectedCallCount;

            action = KeyboardAction.release;
            tclEvalFmt("event generate %s <KeyRelease> -keysym %s -state %s", testWindow.getTclName(), newChar, newKeyMod.toTclValue);
            ++expectedCallCount;
        }
    }

    assert(callCount == expectedCallCount, text(callCount, " != ", expectedCallCount));

    app.testRun();
}

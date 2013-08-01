/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.callback;

import std.stdio;
import std.conv;
import std.c.string;
import std.c.stdlib;
import std.string;

import dtk.utils;
import dtk.event;
import dtk.widget;
import dtk.tcl;

alias Callback = void delegate(Widget, Event);

struct Command
{
    Widget w;
    Callback c;
}

alias Command[int] CallbackMap;

// major todo: these need to be synchronized
__gshared CallbackMap callbackMap;
__gshared int callbackID;
enum callbackPrefix = "dkinter::call";

version = Profile;
version(Profile) import std.datetime;

// called from Tcl
extern (C)
int callbackHandler(ClientData clientData, Tcl_Interp* interp, int objc, const Tcl_Obj** objv)
{
    version(Profile) auto sw = StopWatch(AutoStart.yes);
    int slotID = cast(int)clientData;

    if (auto callback = slotID in callbackMap)
    {
        Event event;

        if (objc > 1)  // todo: objc is the objv count, not sure if we should always assign all fields
        {
            // http://tmml.sourceforge.net/doc/tcl/CrtObjCmd.html
            event.x       = safeToInt(Tcl_GetString(objv[1]));
            event.y       = safeToInt(Tcl_GetString(objv[2]));
            event.keycode = safeToInt(Tcl_GetString(objv[3]));
            event.width   = safeToInt(Tcl_GetString(objv[4]));
            event.height  = safeToInt(Tcl_GetString(objv[5]));
            event.width   = safeToInt(Tcl_GetString(objv[6]));
            event.height  = safeToInt(Tcl_GetString(objv[7]));
        }

        callback.c(callback.w, event);
        version(Profile) sw.stop(); writefln("usecs: %s", sw.peek.usecs);
        return TCL_OK;
    }
    else
    {
        Tcl_SetResult(interp, cast(char*)"Trying to invoke non-existent callback", TCL_STATIC);
        return TCL_ERROR;
    }
}

// called from Tcl
extern (C)
void callbackDeleter(ClientData clientData)
{
    int slotID = cast(int)clientData;
    callbackMap.remove(slotID);
}

int addCallback(Widget wid, Callback clb)
{
    int newSlotID = callbackID;
    callbackID++;  // note: unsafe with threading
    Command c    = Command(wid, clb);
    ClientData d = cast(ClientData)newSlotID;
    char* name   = cast(char*)(callbackPrefix ~ to!string(newSlotID));

    Tcl_CreateObjCommand(wid.interp(),
                         name,
                         &callbackHandler,
                         d,
                         &callbackDeleter);
    callbackMap[newSlotID] = c;
    return newSlotID;
}

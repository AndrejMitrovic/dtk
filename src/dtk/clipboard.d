/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.clipboard;

//~ import std.algorithm;
//~ import std.exception;
//~ import std.range;
//~ import std.stdio;

//~ import dtk.utils;

@property Clipboard clipboard()
{
    return Clipboard();
}

// todo: add clipboard listener
struct Clipboard
{
    //~ // no default ctor workaround
    //~ private static Clipboard get()
    //~ {
        //~ IDataObject pDataObject;
        //~ enforce(OleGetClipboard(&pDataObject) == S_OK);
        //~ scope(exit) pDataObject.Release;
    //~ }

private:
    DropData _dropData;
}

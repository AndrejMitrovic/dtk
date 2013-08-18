/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.dialog;

import std.array;
import std.conv;
import std.exception;
import std.path;
import std.range;
import std.string;

import dtk.app;
import dtk.button;
import dtk.event;
import dtk.signals;
import dtk.types;
import dtk.utils;
import dtk.options;
import dtk.widget;
import dtk.window;

/** A file type marker for use with dialogs. */
struct FileType
{
    string typeName;
    string extension;
    string macType;  /// only required on OSX
}

///
class OpenFileDialog : Widget
{
    ///
    this()
    {
        super(CreateFakeWidget.init);
        _defaultFileTypeVar = this.createTracedTaggedVariable(EventType.TkComboboxChange);
    }

    /**
        Show the dialog using the configured settings and return
        the file the user selected, or an empty string if the
        dialog box was cancelled.
    */
    string show()
    {
        this.setVar(_defaultFileTypeVar, _defaultFileType.typeName);

        version (OSX)
            string msg = format("-message %s", osxMessage._enquote);
        else
            enum string msg = null;

        string newDefFileTypeName = this.getVar!string(_defaultFileTypeVar);
        foreach (fileType; fileTypes)
        {
            if (fileType.typeName == newDefFileTypeName)
            {
                _defaultFileType = fileType;
                break;
            }
        }

        return this.evalFmt("tk_getOpenFile -filetypes %s -initialdir %s -initialfile %s %s -multiple %s %s -title %s -typevariable %s",
            fileTypes.toString(),
            initialDir._enquote,
            initialFile._enquote,
            msg,
            allowMultiSelect,
            (parent is null) ? "" : format("-parent %s", parent._name._enquote),
            title._enquote,
            _defaultFileTypeVar
        ).buildNormalizedPath;
    }

    /**
        Get the current default file type filter in the dialog.
        The default file type filter is tracked between show()
        invocations, if the user selects a different file type filter
        it will be reflected in this call.

        If there are no file type filters, FileType.init is returned.
    */
    @property FileType defaultFileType()
    {
        // ordinarily we'd set the default type when manipulating fileTypes,
        // however due to missing @property rewrites fileTypes is a plain
        // array field and we can't hook into it's writes (unless we define
        // a custom type..)
        if (fileTypes.empty)
            _defaultFileType = FileType.init;
        else
        if (_defaultFileType == FileType.init)
            _defaultFileType = fileTypes[0];

        return _defaultFileType;
    }

    /**
        Set the default file type filter in the dialog.
        If this file type is not in the $(D fileTypes) list,
        it will be added to it.
    */
    @property void defaultFileType(FileType defFileType)
    {
        bool found = false;
        foreach (fileType; fileTypes)
        {
            if (fileType == defFileType)
            {
                found = true;
                break;
            }
        }

        if (!found)
            fileTypes ~= defFileType;

        this.setVar(_defaultFileTypeVar, defFileType.typeName);
    }

    public FileType[] fileTypes;

    public string initialDir;

    public string initialFile;

    public string osxMessage;  /// OSX-specific

    public bool allowMultiSelect;

    public Window parent;

    public string title;

private:
    FileType _defaultFileType;
    string _defaultFileTypeVar;
}

class SaveFileDialog
{
    /**
        Configures how the Save dialog reacts when the
        selected file already exists, and saving would
        overwrite it. A true value requests a confirmation
        dialog be presented to the user. A false value
        requests that the overwrite take place without
        confirmation. Default value is true.
    */
    public bool confirmOverwrite = true;


    public string defaultExtension = "";

}

package string toString(FileType[] fileTypes)
{
    Appender!string result;

    result ~= "{ ";

    foreach (fileType; fileTypes)
    {
        result ~= "{ ";

        result ~= "{";
        result ~= fileType.typeName;
        result ~= "} ";
        result ~= " ";

        result ~= "{";
        result ~= fileType.extension;
        result ~= "} ";

        if (!fileType.macType.empty)
        {
            result ~= " ";
            result ~= fileType.macType;
        }

        result ~= " } ";
    }

    result ~= "}";

    return result.data;
}

///
unittest
{
    auto fileTypes =
    [
        FileType("Text Files", ".txt"),
        FileType("Tcl Scripts", ".tcl"),
        FileType("C Source Files", ".c", "TEXT"),
    ];

    assert(fileTypes.toString() ==
        "{ { {Text Files}  {.txt}  } { {Tcl Scripts}  {.tcl}  } { {C Source Files}  {.c}  TEXT } }");
}

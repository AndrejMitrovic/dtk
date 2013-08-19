/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.widgets.dialog;

import std.array;
import std.conv;
import std.exception;
import std.path;
import std.range;
import std.string;

import dtk.app;
import dtk.color;
import dtk.event;
import dtk.signals;
import dtk.options;
import dtk.types;
import dtk.utils;

import dtk.widgets.button;
import dtk.widgets.widget;
import dtk.widgets.window;

/** A file type marker for use with dialogs. */
struct FileType
{
    string typeName;
    string extension;
    string macType;  /// only required on OSX
}

/// Common code for open and save dialogs
package class GenericDialog : Widget
{
    ///
    this()
    {
        super(CreateFakeWidget.init);
        _defaultFileTypeVar = this.createTracedTaggedVariable(EventType.TkComboboxChange);
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

    package void updateDefaultFileType()
    {
        this.setVar(_defaultFileTypeVar, _defaultFileType.typeName);

        string newDefFileTypeName = this.getVar!string(_defaultFileTypeVar);
        foreach (fileType; fileTypes)
        {
            if (fileType.typeName == newDefFileTypeName)
            {
                _defaultFileType = fileType;
                break;
            }
        }
    }

    public FileType[] fileTypes;

    public string initialDir;

    public string initialFile;

    public string osxMessage;  /// OSX-specific

    public Window parent;

    public string title;

private:
    FileType _defaultFileType;
    string _defaultFileTypeVar;
}

///
class OpenFileDialog : GenericDialog
{
    /**
        Show the dialog using the configured settings and return
        the file the user selected, or an empty string if the
        dialog box was cancelled.
    */
    string show()
    {
        version (OSX)
            string msg = format("-message %s", osxMessage._enquote);
        else
            enum string msg = null;

        this.updateDefaultFileType();

        return this.evalFmt("tk_getOpenFile -filetypes %s -initialdir %s -initialfile %s %s -multiple %s %s -title %s -typevariable %s",
            fileTypes.toString(),
            initialDir._escapePath._enquote,
            initialFile._escapePath._enquote,
            msg,
            allowMultiSelect,
            (parent is null) ? "" : format("-parent %s", parent._name._enquote),
            title._enquote,
            _defaultFileTypeVar
        ).buildNormalizedPath;
    }

    public bool allowMultiSelect;
}

///
class SaveFileDialog : GenericDialog
{
    /**
        Show the dialog using the configured settings and return
        the file the user specified, or an empty string if the
        dialog box was cancelled.
    */
    string show()
    {
        version (OSX)
            string msg = format("-message %s", osxMessage._enquote);
        else
            enum string msg = null;

        this.updateDefaultFileType();

        return this.evalFmt("tk_getSaveFile -filetypes %s -confirmoverwrite %s -defaultextension %s  -initialdir %s -initialfile %s %s %s -title %s -typevariable %s",
            fileTypes.toString(),
            confirmOverwrite,
            defaultExtension,
            initialDir._escapePath._enquote,
            initialFile._escapePath._enquote,
            msg,
            (parent is null) ? "" : format("-parent %s", parent._name._enquote),
            title._enquote,
            _defaultFileTypeVar
        ).buildNormalizedPath;
    }

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

///
class SelectDirDialog : Widget
{
    ///
    this()
    {
        super(CreateFakeWidget.init);
    }

    /**
        Show the dialog using the configured settings and return
        the directory the user selected, or an empty string if the
        dialog box was cancelled.
    */
    string show()
    {
        return this.evalFmt("tk_chooseDirectory -initialdir %s -mustexist %s %s -title %s",
            initialDir._escapePath._enquote,
            mustExist,
            (parent is null) ? "" : format("-parent %s", parent._name._enquote),
            title._enquote,
        ).buildNormalizedPath;
    }

    public string initialDir;

    public bool mustExist;

    public Window parent;

    public string title;
}

class SelectColorDialog : Widget
{
    ///
    this()
    {
        super(CreateFakeWidget.init);
    }

    /**
        Show the dialog using the configured settings and return
        the color the user selected.
    */
    Result show()
    {
        Result result;

        string output = this.evalFmt("tk_chooseColor %s %s -title %s",
            !_useInitColor ? "" : format("-initialcolor %s", _initColor.toString()),
            (parent is null) ? "" : format("-parent %s", parent._name._enquote),
            title._enquote,
        ).buildNormalizedPath;

        if (!output.empty)
        {
            result.hasAccepted = true;
            result.color = output.toRGB;
        }

        return result;
    }

    ///
    static struct Result
    {
        bool hasAccepted;
        RGB color;
    }

    public Window parent;

    public string title;

    @property RGB initialColor()
    {
        return _initColor;
    }

    @property void initialColor(RGB newInitColor)
    {
        _useInitColor = true;
        _initColor = newInitColor;
    }

private:
    bool _useInitColor;
    RGB _initColor;
}

/** The types of button groups usable in a message box. */
enum MessageBoxType
{
    abort_retry_ignore, ///
    ok,                 ///
    ok_cancel,          ///
    retry_cancel,       ///
    yes_no,             ///
    yes_no_cancel,      ///
}

/** The type of a button that is placeable and selectable in a message box. */
enum MessageButtonType
{
    none,
    abort,
    retry,
    ignore,
    ok,
    cancel,
    yes,
    no,
}

enum MessageBoxIcon
{
    info,
    question,
    warning,
    error,
}

class MessageBox : Widget
{
    ///
    this()
    {
        super(CreateFakeWidget.init);
    }

    /**
        Show the message using the configured settings and return
        the button the the user selected.
    */
    MessageButtonType show()
    {
        string strDefault = (defaultButtonType == MessageButtonType.none)
                          ? "" : format("-default %s", defaultButtonType);

        version (OSX)
            enum titleStr = "";  // title unused on OSX
        else
            string titleStr = format("-title %s", title._enquote);

        string result = this.evalFmt("tk_messageBox %s -detail %s -icon %s -message %s %s %s -type %s",
            strDefault,
            extraMessage._enquote,
            messageBoxIcon,
            message._enquote,
            (parent is null) ? "" : format("-parent %s", parent._name._enquote),
            titleStr,
            messageBoxType.toString());

        return to!MessageButtonType(result);
    }

    public MessageButtonType defaultButtonType;

    public MessageBoxIcon messageBoxIcon;

    public string message;

    public string extraMessage;

    public Window parent;

    public string title;

    public MessageBoxType messageBoxType;
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

package string toString(MessageBoxType messageBoxType)
{
    final switch (messageBoxType) with (MessageBoxType)
    {
        case abort_retry_ignore: return "abortretryignore";
        case ok:                 return "ok";
        case ok_cancel:          return "okcancel";
        case retry_cancel:       return "retrycancel";
        case yes_no:             return "yesno";
        case yes_no_cancel:      return "yesnocancel";
    }
}

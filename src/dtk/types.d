/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.types;

/**
    This module contains just a small portion of the Tcl/Tk declarations.
*/

import core.stdc.config : c_long, c_ulong;

import std.array;
import std.exception;

import dtk.utils;

enum uint TCL_OK = 0;
enum uint TCL_ERROR = 1;
enum uint TCL_RETURN = 2;
enum uint TCL_BREAK = 3;
enum uint TCL_CONTINUE = 4;

struct _XIC
{
    @disable this();
    @disable this(this);
}

alias XIC = _XIC*;

struct CData
{
    @disable this();
    @disable this(this);
}

/// opaque handle to client data
alias ClientData = CData*;

alias extern(C) void function(Tcl_Obj objPtr) Tcl_FreeInternalRepProc;
alias extern(C) void function(ClientData clientData) Tcl_CmdDeleteProc;
alias extern(C) int function(ClientData clientData, Tcl_Interp* interp, int objc, const Tcl_Obj **objv) Tcl_ObjCmdProc;
alias extern(C) void function(Tcl_Obj srcPtr, Tcl_Obj dupPtr) Tcl_DupInternalRepProc;
alias extern(C) void function(Tcl_Obj objPtr) Tcl_UpdateStringProc;
alias extern(C) int function(Tcl_Interp* interp, Tcl_Obj objPtr) Tcl_SetFromAnyProc;
alias extern(C) long  Tcl_WideInt;
alias extern(C) ulong Tcl_WideUInt;
alias extern(C) void function(char* blockPtr) Tcl_FreeProc;

const Tcl_FreeProc* TCL_STATIC = cast(Tcl_FreeProc*)0;

struct Tk_Window_
{
    @disable this();
    @disable this(this);
}

/// opaque handle to a window
alias Tk_Window = Tk_Window_*;

version(X86_64)
    alias XID = long;
else
    alias XID = c_ulong;

alias Tk_Window_XID = XID;

alias Tk_Uid = const(char)*;

/*
 * Data structure for XReconfigureWindow
 */
//~ struct XWindowChanges
//~ {
    //~ int x, y;
    //~ int width, height;
    //~ int border_width;
    //~ Window sibling;
    //~ int stack_mode;
//~ }

/*
 * Data structure for setting window attributes.
 */
//~ struct XSetWindowAttributes
//~ {
    //~ Pixmap background_pixmap;	/* background or None or ParentRelative */
    //~ unsigned long background_pixel;	/* background pixel */
    //~ Pixmap border_pixmap;	/* border of the window */
    //~ unsigned long border_pixel;	/* border pixel value */
    //~ int bit_gravity;		/* one of bit gravity values */
    //~ int win_gravity;		/* one of the window gravity values */
    //~ int backing_store;		/* NotUseful, WhenMapped, Always */
    //~ unsigned long backing_planes;/* planes to be preseved if possible */
    //~ unsigned long backing_pixel;/* value to use in restoring planes */
    //~ Bool save_under;		/* should bits under be saved? (popups) */
    //~ long event_mask;		/* set of events that should be saved */
    //~ long do_not_propagate_mask;	/* set of events that should not propagate */
    //~ Bool override_redirect;	/* boolean value for override-redirect */
    //~ Colormap colormap;		/* color map to be associated with window */
    //~ Cursor cursor;		/* cursor to be displayed (or None) */
//~ };

struct Tk_FakeWin
{
    /* Display */ void *display;
    char *dummy1;		/* dispPtr */
    int screenNum;
    /* Visual */ void *visual;
    int depth;
    Tk_Window_XID window;
    //~ char *dummy2;		/* childList */
    //~ char *dummy3;		/* lastChildPtr */
    //~ Tk_Window parentPtr;	/* parentPtr */
    //~ char *dummy4;		/* nextPtr */
    //~ char *dummy5;		/* mainPtr */
    //~ char *pathName;
    //~ Tk_Uid nameUid;
    //~ Tk_Uid classUid;
    //~ XWindowChanges changes;
    //~ uint dummy6;	/* dirtyChanges */
    //~ XSetWindowAttributes atts;
    //~ c_ulong dummy7;	/* dirtyAtts */
    //~ uing flags;
    //~ char *dummy8;		/* handlerList */
//~ #ifdef TK_USE_INPUT_METHODS
    //~ XIC dummy9;			/* inputContext */
//~ #endif /* TK_USE_INPUT_METHODS */
    //~ ClientData *dummy10;	/* tagPtr */
    //~ int dummy11;		/* numTags */
    //~ int dummy12;		/* optionLevel */
    //~ char *dummy13;		/* selHandlerList */
    //~ char *dummy14;		/* geomMgrPtr */
    //~ ClientData dummy15;		/* geomData */
    //~ int reqWidth, reqHeight;
    //~ int internalBorderLeft;
    //~ char *dummy16;		/* wmInfoPtr */
    //~ char *dummy17;		/* classProcPtr */
    //~ ClientData dummy18;		/* instanceData */
    //~ char *dummy19;		/* privatePtr */
    //~ int internalBorderRight;
    //~ int internalBorderTop;
    //~ int internalBorderBottom;
    //~ int minReqWidth;
    //~ int minReqHeight;
    //~ char *dummy20;		/* geometryMaster */
}

struct Tcl_Command_
{
    @disable this();
    @disable this(this);
}

/// opaque handle to a command
alias Tcl_Command = Tcl_Command_*;

alias extern(C) void function(char* blockPtr) FreeProc;

enum TCL_DONT_WAIT      = (1<<1);
enum TCL_WINDOW_EVENTS  = (1<<2);
enum TCL_FILE_EVENTS    = (1<<3);
enum TCL_TIMER_EVENTS   = (1<<4);
enum TCL_IDLE_EVENTS    = (1<<5);  /* WAS 0x10 ???? */
enum TCL_ALL_EVENTS     = (~TCL_DONT_WAIT);

/// The type of the $(D timeMsec) field in an event.
public alias TimeMsec = c_ulong;

/**
    Get the current Tcl time. Equivalent to the implementation of
    $(B TkpGetMS) in the Tk library, which uses $(B Tcl_GetTime)
*/
TimeMsec getTclTime()
{
    Tcl_Time now;

    Tcl_GetTime(&now);

    // note: in Tk they cast this to long, might be a bug since Time is defined as:
    // xlib\x11\X.h: 'typedef unsigned long Time;'
    return cast(TimeMsec)now.sec * 1000 + now.usec / 1000;
}

struct Tcl_Time
{
    c_long sec;  /* Seconds. */
    c_long usec; /* Microseconds. */
}

/*
 * Using structs so I can iterate the members via __traits(allMembers, TclProcs).
 * This simplifies loading the symbols dynamically.
 */
struct TclProcs
{
__gshared extern(C):
    // Note: We must call this function before any other TCL function
    void function(const char* argv0) Tcl_FindExecutable;
    const(char*) function() Tcl_GetNameOfExecutable;
    int function(Tcl_Interp* interp, char* str) Tcl_Eval;
    Tcl_Interp* function() Tcl_CreateInterp;
    char* function(Tcl_Obj * objPtr, int* lengthPtr) Tcl_GetStringFromObj;
    char* function(const Tcl_Obj * objPtr) Tcl_GetString;
    char* function(Tcl_Interp* interp, char* str, int flags) Tcl_GetVar;
    Tcl_Obj* function(Tcl_Interp* interp, char* name1, char* name2, int flags) Tcl_GetVar2Ex;
    //~ Tcl_Obj* function(Tcl_Interp* interp, char* name1, char* name2, int flags) Tcl_SetVar2Ex;
    char* function(Tcl_Interp* interp, char* str, char* newValue, int flags) Tcl_SetVar;
    char* function(Tcl_Interp* interp, char* name1, char* name2, char* newValue, int flags) Tcl_SetVar2;
    void function(Tcl_Interp* interp, char* str, Tcl_FreeProc* freeProc) Tcl_SetResult;
    Tcl_Command function(Tcl_Interp* interp, char* cmdName,
                                      Tcl_ObjCmdProc proc, ClientData clientData,
                                      Tcl_CmdDeleteProc deleteProc) Tcl_CreateObjCommand;

    int function(Tcl_Interp* interp, const(Tcl_Obj)* listPtr, int* objcPtr, Tcl_Obj*** objvPtr) Tcl_ListObjGetElements;

    int function(Tcl_Interp* interp) Tcl_Init;
    void function(Tcl_Interp* interp) Tcl_DeleteInterp;
    int function(int flags) Tcl_DoOneEvent;
    void function(Tcl_Time* timeBuf) Tcl_GetTime;
}

version(Windows)
{
    import dtk.platform.win32.defs;
}

/*
 * Data structure for setting graphics context.
 */
//~ struct XGCValues
//~ {
	//~ int function;		/* logical operation */
	//~ unsigned long plane_mask;/* plane mask */
	//~ unsigned long foreground;/* foreground pixel */
	//~ unsigned long background;/* background pixel */
	//~ int line_width;		/* line width */
	//~ int line_style;	 	/* LineSolid, LineOnOffDash, LineDoubleDash */
	//~ int cap_style;	  	/* CapNotLast, CapButt,
				   //~ CapRound, CapProjecting */
	//~ int join_style;	 	/* JoinMiter, JoinRound, JoinBevel */
	//~ int fill_style;	 	/* FillSolid, FillTiled,
				   //~ FillStippled, FillOpaeueStippled */
	//~ int fill_rule;	  	/* EvenOddRule, WindingRule */
	//~ int arc_mode;		/* ArcChord, ArcPieSlice */
	//~ Pixmap tile;		/* tile pixmap for tiling operations */
	//~ Pixmap stipple;		/* stipple 1 plane pixmap for stipping */
	//~ int ts_x_origin;	/* offset for tile or stipple operations */
	//~ int ts_y_origin;
        //~ Font font;	        /* default text font for text operations */
	//~ int subwindow_mode;     /* ClipByChildren, IncludeInferiors */
	//~ Bool graphics_exposures;/* boolean, should exposures be generated */
	//~ int clip_x_origin;	/* origin for clipping */
	//~ int clip_y_origin;
	//~ Pixmap clip_mask;	/* bitmap clipping; other calls for rects */
	//~ int dash_offset;	/* patterned/dashed line information */
	//~ char dashes;
//~ }

/*
 * Graphics context.  The contents of this structure are implementation
 * dependent.  A GC should be treated as opaque by application code.
 */

//~ alias GC = XGCValues*;

struct TkProcs
{
__gshared extern(C):
    int function(Tcl_Interp* interp) Tk_Init;
    Tk_Window function(Tcl_Interp* interp) Tk_MainWindow;
    void function() Tk_MainLoop;
    Tk_Window function(Tcl_Interp* interp, const(char)* pathName, Tk_Window tkwin) Tk_NameToWindow;
    int function() Tk_GetNumMainWindows;

    version(Windows)
    {
        HWND function(Tk_Window_XID window) Tk_GetHWND;
        Tk_Window function(HWND hwnd) Tk_HWNDToWindow;
    }

    //~ GC function(Tk_Window tkwin, c_ulong valueMask, XGCValues *valuePtr) Tk_GetGC;
}

Tk_Window_XID Tk_WindowId(Tk_Window tkwin)
{
    return (cast(Tk_FakeWin*)tkwin).window;
}

mixin ExportMembers!TkProcs;
mixin ExportMembers!TclProcs;

struct Tcl_Interp
{
    char* result;               /* If the last command returned a string
                                 * result, this points to it. */
    FreeProc freeProc;

    /* Zero means the string result is
     * statically allocated. TCL_DYNAMIC means
     * it was allocated with ckalloc and should
     * be freed with ckfree. Other values give
     * the address of procedure to invoke to
     * free the result. Tcl_Eval must free it
     * before executing next command. */
    int errorLine;              /* When TCL_ERROR is returned, this gives
                                 * the line number within the command where
                                 * the error occurred (1 if first line). */
}

struct Tcl_ObjType
{
    char* name;                 /* Name of the type, e.g. "int". */
    Tcl_FreeInternalRepProc* freeIntRepProc;

    /* Called to free any storage for the type's
     * internal rep. NULL if the internal rep
     * does not need freeing. */
    Tcl_DupInternalRepProc* dupIntRepProc;

    /* Called to create a new object as a copy
     * of an existing object. */
    Tcl_UpdateStringProc* updateStringProc;

    /* Called to update the string rep from the
     * type's internal representation. */
    Tcl_SetFromAnyProc* setFromAnyProc;

    /* Called to convert the object's internal
     * rep to this type. Frees the internal rep
     * of the old type. Returns TCL_ERROR on
     * failure. */
}

/*
 * One of the following structures exists for each object in the Tcl
 * system. An object stores a value as either a string, some internal
 * representation, or both.
 */
struct Tcl_Obj
{
    int refCount;               /* When 0 the object will be freed. */
    char* bytes;                /* This points to the first byte of the
                                 * object's string representation. The array
                                 * must be followed by a null byte (i.e., at
                                 * offset length) but may also contain
                                 * embedded null characters. The array's
                                 * storage is allocated by ckalloc. NULL
                                 * means the string rep is invalid and must
                                 * be regenerated from the internal rep.
                                 * Clients should use Tcl_GetStringFromObj
                                 * or Tcl_GetString to get a pointer to the
                                 * byte array as a readonly value. */
    int length;                 /* The number of bytes at *bytes, not
                                 * including the terminating null. */
    Tcl_ObjType* typePtr;       /* Denotes the object's type. Always
                                 * corresponds to the type of the object's
                                 * internal rep. NULL indicates the object
                                 * has no internal rep (has no type). */
    union internalRep_          /* The internal representation: */
    {
        int intValue;           /*   - an int integer value */
        double doubleValue;     /*   - a double-precision floating value */
        void* otherValuePtr;    /*   - another, type-specific value */
        Tcl_WideInt wideValue;  /*   - a int value */
        struct twoPtrValue_     /*   - internal rep as two pointers */
        {
            void* ptr1;
            void* ptr2;
        }

        twoPtrValue_ twoPtrValue;
    }

    internalRep_ internalRep;
}

/// Tk and Ttk widget types
package enum TkType : string
{
    button      = "ttk::button",
    checkbutton = "ttk::checkbutton",
    combobox    = "ttk::combobox",
    entry       = "ttk::entry",
    frame       = "ttk::frame",
    label       = "ttk::label",
    labelframe  = "ttk::labelframe",
    listbox     = "tk::listbox",     // note: no ttk::listbox yet in v8.6
    menu        = "menu",            // note: no ttk::menu
    notebook    = "ttk::notebook",
    panedwindow = "ttk::panedwindow",
    progressbar = "ttk::progressbar",
    radiobutton = "ttk::radiobutton",
    scale       = "ttk::scale",
    separator   = "ttk::separator",
    sizegrip    = "ttk::sizegrip",
    scrollbar   = "ttk::scrollbar",
    spinbox     = "ttk::spinbox",
    text        = "tk::text",        // note: no ttk::text
    toplevel    = "tk::toplevel",    // note: no ttk::toplevel
    tree        = "ttk::treeview",
}

///
package string toString(TkType tkType)
{
    // note: cannot use :: in name because it can sometimes be
    // interpreted in a special way, e.g. tk hardcodes some
    // methods to ttk::type.func.name
    return tkType.replace(":", "_");
}

/// Tk class types for each widget type
package enum TkClass : string
{
    button      = "TButton",
    checkbutton = "TCheckbutton",
    combobox    = "TCombobox",
    entry       = "TEntry",
    frame       = "TFrame",
    label       = "TLabel",
    labelframe  = "TLabelframe",
    listbox     = "Listbox",
    menu        = "Menu",
    notebook    = "TNotebook",
    panedwindow = "TPanedwindow",
    progressbar = "TProgressbar",
    radiobutton = "TRadiobutton",
    scale       = "TScale",
    separator   = "TSeparator",
    sizegrip    = "TSizegrip",
    scrollbar   = "TScrollbar",
    spinbox     = "TSpinbox",
    text        = "Text",
    toplevel    = "Toplevel",
    tree        = "Treeview",
}

///
package TkClass toTkClass(TkType tkType)
{
    // note: safe since to!string will return the member name, not the string value
    return to!TkClass(to!string(tkType));
}

///
package enum TkSubs : string
{
    client_request = "%#",
    win_below_target = "%a",
    mouse_button = "%b",
    count = "%c",
    detail = "%d",
    focus = "%f",
    height = "%h",
    win_hex_id = "%i",
    keycode = "%k",
    mode = "%m",
    override_redirect = "%o",
    place = "%p",
    state = "%s",
    timestamp = "%t",
    width = "%w",
    rel_x_pos = "%x",
    rel_y_pos = "%y",
    uni_char = "%A",
    border_width = "%B",
    mouse_wheel_delta = "%D",
    send_event_type = "%E",
    keysym_text = "%K",
    keysym_decimal = "%N",
    property_name = "%P",
    root_window_path = "%R",
    subwindow_path = "%S",
    type = "%T",
    widget_path = "%W",
    abs_x_pos = "%X",
    abs_y_pos = "%Y",
}

// All possible mouse bind target options
package enum TkMouseAction
{
    press,
    release,
    motion,
    wheel,
}

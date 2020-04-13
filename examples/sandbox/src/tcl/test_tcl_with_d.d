import core.sys.windows.windows;
import std.stdio;

alias extern(C) void* function() Tcl_CreateInterp_Type;
alias extern(C) int function(void*) Tcl_Init_Type;
alias extern(C) int function(void*) Tk_Init_Type;
alias extern(C) int function(void*, const(char)*) Tcl_Eval_Type;
alias extern(C) void function() Tk_MainLoop_Type;

int main()
{
    HMODULE hTcl = LoadLibraryA("tcl86.dll");
    HMODULE hTk = LoadLibraryA("tk86.dll");

    Tcl_CreateInterp_Type Tcl_CreateInterp;
    Tcl_CreateInterp = cast(Tcl_CreateInterp_Type)GetProcAddress(hTcl, "Tcl_CreateInterp");

    Tcl_Init_Type Tcl_Init;
    Tcl_Init = cast(Tcl_Init_Type)GetProcAddress(hTcl, "Tcl_Init");

    Tk_Init_Type Tk_Init;
    Tk_Init = cast(Tk_Init_Type)GetProcAddress(hTk, "Tk_Init");

    Tcl_Eval_Type Tcl_Eval;
    Tcl_Eval = cast(Tcl_Eval_Type)GetProcAddress(hTcl, "Tcl_Eval");

    Tk_MainLoop_Type Tk_MainLoop;
    Tk_MainLoop = cast(Tk_MainLoop_Type)GetProcAddress(hTk, "Tk_MainLoop");

    void* _interp = Tcl_CreateInterp();
    Tcl_Init(_interp);
    Tk_Init(_interp);

    Tcl_Eval(_interp, "tkwait visibility .");
    Tcl_Eval(_interp, "tk::toplevel .mywin");
    Tcl_Eval(_interp, "wm resizable .mywin false false");

    Tk_MainLoop();

    return 0;
}

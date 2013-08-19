/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.app;

import std.stdio;
import std.c.stdlib;

import std.exception;
import std.string;
import std.conv;
import std.path;

import dtk.event;
import dtk.loader;
import dtk.types;

import dtk.widgets.widget;
import dtk.widgets.window;

/** The main dtk application. Once instantiated a main window will be created. */
final class App
{
    /** Create the app and a main window. */
    this()
    {
        _interp = enforce(Tcl_CreateInterp());

        enforce(Tcl_Init(_interp) == TCL_OK, to!string(_interp.result));
        enforce(Tk_Init(_interp) == TCL_OK, to!string(_interp.result));

        _window = new Window(enforce(Tk_MainWindow(_interp)));
    }

    version(unittest)
    version(DTK_UNITTEST)
    {
        import std.datetime;

        static string _file;
        static size_t _line;

        void testRun(Duration runTime = 0.seconds, SkipIdleTime skipIdleTime = SkipIdleTime.yes, string file = __FILE__, size_t line = __LINE__)
        {
            _file = file;
            _line = line;
            auto displayTimer = StopWatch(AutoStart.yes);

            auto runTimeDur = cast(TickDuration)runTime;
            auto runTimeWatch = StopWatch(AutoStart.yes);

            bool idleDurChanged = false;

            this.setupExitHandler();

            // if the user explicitly closes the window while testing, we break out of the whole test-suite.
            eval("
            wm protocol . WM_DELETE_WINDOW {
                ::dtk_early_exit
            }");

            bool hasEvents = false;

            do
            {
                hasEvents = Tcl_DoOneEvent(TCL_DONT_WAIT) != 0;

                // event found, add some idle time to allow processing
                if (skipIdleTime == skipIdleTime.no && hasEvents)
                {
                    runTime += 100.msecs;
                    runTimeDur = cast(TickDuration)runTime;
                    idleDurChanged = true;
                }

                if (displayTimer.peek > cast(TickDuration)(1.seconds))
                {
                    if (idleDurChanged)
                    {
                        idleDurChanged = false;
                        auto durSecs = runTimeDur.seconds;
                        auto durMsecs = runTimeDur.msecs - (durSecs * 1000);
                        stderr.writefln("-- Idle time increased to: %s seconds, %s msecs.", durSecs, durMsecs);
                    }

                    displayTimer.reset();
                    auto timeLeft = runTimeDur - runTimeWatch.peek;
                    stderr.writefln("-- Time left: %s seconds.", (runTimeDur - runTimeWatch.peek).seconds);
                }

            } while (hasEvents || runTimeWatch.peek < runTimeDur);

            // clean out all widgets for this test run

            // @bug: Strange hash symbol for menus on default "." top-level window, e.g. .#mymenu:
            // See: http://stackoverflow.com/q/18290171/279684
            foreach (widget; mainWindow.childWidgets)
            {
                if (widget !is null)
                    widget.destroy();
            }

            // @bug: still doesn't work, we still can't destroy the .#mymenu for some reason, likely a Tk bug
            /+ string paths = evalFmt("winfo children %s", mainWindow._name);
            foreach (path; paths.splitter)
            {
                stderr.writefln("path: %s", path);
                evalFmt("destroy %s", path);
            } +/
        }

        private void setupExitHandler()
        {
            Tcl_CreateObjCommand(App._interp,
                                 cast(char*)"::dtk_early_exit",
                                 &callbackHandler,
                                 null,
                                 &callbackDeleter);
        }


        static extern(C)
        void callbackDeleter(ClientData clientData) { }

        static extern(C)
        int callbackHandler(ClientData clientData, Tcl_Interp* interp, int objc, const Tcl_Obj** objv)
        {
            assert(0, format("\nError: User invoked early exit, test-case in %s(%s) failed.", _file, _line));
        }
    }

    /** Start the App event loop. */
    void run()
    {
        scope(exit)
            this.exit();

        Tk_MainLoop();
    }

    /** Return the main app window. */
    @property Window mainWindow()
    {
        return _window;
    }

    public static string evalFmt(T...)(string fmt, T args)
    {
        return eval(format(fmt, args));
    }

    /** Evaluate any Tcl command and return its result. */
    public static string eval(string cmd)
    {
        version (DTK_LOG_EVAL)
            stderr.writefln("tcl_eval %s", cmd);

        Tcl_Eval(_interp, cast(char*)toStringz(cmd));
        return to!string(_interp.result);
    }

    void exit()
    {
        Tcl_DeleteInterp(_interp);
    }

package:
    /** Only one interpreter is allowed. */
    __gshared Tcl_Interp* _interp;

private:
    Window _window;
}

version(unittest)
version(DTK_UNITTEST)
{
    /**
        Some test-cases create a lot of idle events (e.g. an indeterminate progress bar).
        In such cases an event should not increase the waiting time before the app is closed.
    */
    enum SkipIdleTime
    {
        no,
        yes
    }
}

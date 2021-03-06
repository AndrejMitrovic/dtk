/*
 *         Copyright Andrej Mitrovic 2013 - 2020.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.app;

import dtk.event;
import dtk.interpreter;
import dtk.loader;
import dtk.types;
import dtk.utils;
import dtk.widgets.widget;
import dtk.widgets.window;

import std.datetime.stopwatch;
import std.exception;

import core.thread;

/** The main dtk application. Once instantiated a main window will be created. */
class App
{
    /** Create the app and a main window. */
    this()
    {
        enforce(!_isAppInited, "Cannot have more than one App instance.");
        _isAppInited = true;
        _window = new Window(enforce(Tk_MainWindow(tclInterp), "Couldn't retrieve the main Tk toplevel window."));
    }

    version(unittest)
    {
        import std.format;
        import std.stdio;

        private struct UnitTestData
        {
            // file + line of where testRun() was invoked
            string file;
            size_t line;
        }

        /// Run an event loop for the test-suite
        void testRun(Duration runTime = 0.seconds, string file = __FILE__, size_t line = __LINE__)
        {
            _isAppRunning = true;
            auto displayTimer = StopWatch(AutoStart.yes);

            auto runTimeDur = runTime;
            auto runTimeWatch = StopWatch(AutoStart.yes);

            bool idleDurChanged = false;

            UnitTestData ut_data = { file : file, line : line };
            Tcl_CreateObjCommand(tclInterp,
                                 "::dtk_early_exit",
                                 &callbackHandler,
                                 cast(ClientData)&ut_data,
                                 &callbackDeleter);

            // if the user explicitly closes the window while testing, we break out of the whole test-suite.
            tclEval("
            wm protocol . WM_DELETE_WINDOW {
                ::dtk_early_exit
            }");

            bool hasEvents = false;

            do
            {
                hasEvents = Tcl_DoOneEvent(TCL_DONT_WAIT) != 0;

                if (displayTimer.peek > 1.seconds)
                {
                    if (idleDurChanged)
                    {
                        idleDurChanged = false;
                        stderr.writefln("-- Idle time increased to: %s.", runTimeDur);
                    }

                    displayTimer.reset();
                    auto timeLeft = runTimeDur - runTimeWatch.peek;
                    stderr.writefln("-- Time left: %s.", runTimeDur - runTimeWatch.peek);
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

        static extern(C)
        void callbackDeleter(ClientData clientData) nothrow { }

        static extern(C)
        int callbackHandler(ClientData clientData, Tcl_Interp* interp, int objc, const Tcl_Obj** objv)
        {
            auto ud = cast(UnitTestData*)clientData;
            assert(0, format("\nError: User invoked early exit, test-case in %s(%s) failed.",
                ud.file, ud.line));
        }
    }

    /** Start the App event loop. */
    void run()
    {
        assert(!_isAppRunning, "Cannot call App.run() more than once.");

        _isAppRunning = true;
        scope(exit) _isAppRunning = false;

        bool hasEvents;
        auto eventTimer = StopWatch(AutoStart.yes);

        tclEvalFmt("tkwait visibility %s", _window._name);

        /**
            Main event loop. This is equivalent to Tk_MainLoop(),
            except we make sure any exceptions caught get re-thrown
            here.

            Docs:
            Tcl_DoOneEvent: http://www.tcl.tk/man/tcl8.6/TclLib/DoOneEvent.htm
            Tcl_DoWhenIdle: http://www.tcl.tk/man/tcl8.6/TclLib/DoWhenIdle.htm
        */
        while (Tk_GetNumMainWindows() > 0)
        {
            hasEvents = Tcl_DoOneEvent(TCL_DONT_WAIT) != 0;
            if (hasEvents)
                eventTimer.reset();

            checkExceptions();

            if (!hasEvents && eventTimer.peek > 1.msecs)
                Thread.sleep(1.msecs);
        }
    }

    /** Return the main app window. */
    @property Window mainWindow()
    {
        return _window;
    }

    private static void checkExceptions()
    {
        if (thrownThrowable !is null)
        {
            auto throwable = thrownThrowable;
            thrownThrowable = null;
            throw throwable;
        }
        else
        if (thrownError !is null)
        {
            auto error = thrownError;
            thrownError = null;
            throw error;
        }
        else
        if (thrownException !is null)
        {
            auto exception = thrownException;
            thrownException = null;
            throw exception;
        }
    }

package:
    __gshared bool _isAppRunning;

    static Throwable thrownThrowable;
    static Error thrownError;
    static Exception thrownException;

private:
    Window _window;
    __gshared bool _isAppInited;
}


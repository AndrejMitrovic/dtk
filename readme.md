# dtk

![dtk](https://raw.github.com/AndrejMitrovic/rtaudiod/master/screenshots/work_in_progress.png)

# NOTE: This project is currently being updated to work with the latest compilers. Please have patience.

This is a D wrapper of the Tcl/Tk graphics library. It is based on Tcl/Tk v8.6.0.0.

Currently **dtk** has been tested on **Windows 7 x64** and **Linux Manjaro XFCE 0.8.9 x64**.

However, drag & drop has currently only been implemented on Windows.

Drag & drop is not a built-in feature of Tk but is provided by the D wrapper.

Homepage: https://github.com/AndrejMitrovic/dtk

## Requirements

Before using **dtk** you will need to install the **Tcl** and **Tk** shared libraries,
versioned at **v8.6.0.0** or newer.

### Installing Tcl/Tk on Windows

You can download and install the [ActiveTcl] distribution.

**Note:** You may need to log off in Windows and then log in again to update your `PATH`
environment variable.

Otherwise **dtk** will not find the **Tk** and **Tcl** DLLs.

### Installing Tcl/Tk on Posix

Use your package manager to install the **Tk** and **Tcl** shared libraries.

## Examples

Use [dub] to run any of the examples. Simply prepend `dub run dtk:` before the example name when calling [dub]:

```
$ dub run dtk:buttons
```

Also try **menus**, **images**, and other examples found in the **examples** folder.

You can also `cd` into an example's directory and call `dub` to run that example.

## Building dtk as a static library

Run [dub] alone in the root project directory to build **dtk** as a static library:

```
$ dub
```

## Documentation

Documentation and tutorials are planned to be written soon. Stay tuned!

## Links

- ActiveTcl Tcl/Tk distribution: http://www.activestate.com/activetcl/downloads
- Tcl v8.6 reference links: http://www.tcl.tk/man/tcl8.6/
- Tcl v8.6 Tcl commands: http://www.tcl.tk/man/tcl8.6/TclCmd/contents.htm
- Tcl v8.6 Tk commands: http://www.tcl.tk/man/tcl8.6/TkCmd/contents.htm
- Tcl Wiki book: http://en.wikibooks.org/wiki/Tcl_Programming/Tk
- Tk tutorial: http://www.tkdocs.com/

## License

Distributed under the [Boost Software License][BoostLicense], Version 1.0.

See the accompanying file [license.txt](https://raw.github.com/AndrejMitrovic/dtk/master/license.txt) or an online copy [here][BoostLicense].

[BoostLicense]: http://www.boost.org/LICENSE_1_0.txt
[dub]: http://code.dlang.org/download
[ActiveTcl]: http://www.activestate.com/activetcl

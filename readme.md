# dtk

![dtk](https://raw.github.com/AndrejMitrovic/dtk/v0.x.x/screenshots/work-in-progress.png)

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

You can download and extract the [IronTcl] distribution.

**Note:** You need to add the path to the IronTcl Tcl/Tk DLLs into your `PATH`
environment variable, or alternatively copy the Tcl/Tk DLLs into the current
path of your executable.

### Installing Tcl/Tk on Posix

Use your package manager to install the **Tk** and **Tcl** shared libraries.

For example:

```
$ sudo apt-get install -y tk8.6
```

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

## Testing

You can test individual modules with:

$ dtest=dtk.tests.events_keyboard dub test

## Documentation

Documentation and tutorials are planned to be written soon. Stay tuned!

## Links

- IronTcl Tcl/Tk distribution: https://www.irontcl.com/
- Tcl v8.6 reference links: http://www.tcl.tk/man/tcl8.6/
- Tcl v8.6 Tcl commands: http://www.tcl.tk/man/tcl8.6/TclCmd/contents.htm
- Tcl v8.6 Tk commands: http://www.tcl.tk/man/tcl8.6/TkCmd/contents.htm
- Tcl Wiki book: http://en.wikibooks.org/wiki/Tcl_Programming/Tk
- Tk tutorial: http://www.tkdocs.com/

## License

Distributed under the [Boost Software License][BoostLicense], Version 1.0.

See the accompanying file [license](https://raw.github.com/AndrejMitrovic/dtk/v0.x.x/LICENSE) or an online copy [here][BoostLicense].

[BoostLicense]: http://www.boost.org/LICENSE_1_0.txt
[dub]: http://code.dlang.org/download
[IronTcl]: https://www.irontcl.com/

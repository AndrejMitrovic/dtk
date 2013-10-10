/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.style;

import dtk.interpreter;

struct Style
{
    package this(string name)
    {
        _name = name;
    }

    @property string name()
    {
        return _name;
    }

private:
    string _name;
}

// todo: populate these with all widget types, and add these to the test_styles test-suite
enum GenericStyle : Style
{
    none = Style(""),
    button = Style("TButton"),
    toolButton = Style("Toolbutton"),
    checkButton = Style("TCheckbutton"),
}

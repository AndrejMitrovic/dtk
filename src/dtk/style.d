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

enum GenericStyle : Style
{
    none         = Style(""),
    button       = Style("TButton"),
    toolButton   = Style("Toolbutton"),
    checkButton  = Style("TCheckbutton"),
    combobox     = Style("TCombobox"),
    entry        = Style("TEntry"),
    frame        = Style("TFrame"),
    label        = Style("TLabel"),
    labelFrame   = Style("TLabelframe"),
    menu         = Style(""),             // todo: test when menu API is stabilized
    menuButton   = Style("TMenubutton"),  // todo: test when menuButton is ported
    notebook     = Style("TNotebook"),
    panedWindow  = Style("TPanedwindow"),
    progressbar  = Style("TProgressbar"),
    radioButton  = Style("TRadiobutton"),
    slider       = Style("TScale"),
    scrollbar    = Style("TScrollbar"),
    separator    = Style("TSeparator"),
    spinbox      = Style("TSpinbox"),
    text         = Style(""),
    window       = Style(""),
    tree         = Style("Treeview"),
}

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

    string toString()
    {
        return name;
    }

private:
    string _name;
}

enum DefaultStyle : Style
{
    none         = Style(""),
    button       = Style("TButton"),
    checkButton  = Style("TCheckbutton"),
    combobox     = Style("TCombobox"),
    entry        = Style("TEntry"),
    frame        = Style("TFrame"),
    label        = Style("TLabel"),
    labelFrame   = Style("TLabelframe"),
    menu         = Style(""),             // todo: test when menu API is stabilized
    menuButton   = Style("TMenubutton"),  // todo: test when menuButton is ported
    notebook     = Style("TNotebook"),
    pane         = Style("TPanedwindow"),
    vProgressbar = Style("Vertical.TProgressbar"),
    hProgressbar = Style("Horizontal.TProgressbar"),
    radioButton  = Style("TRadiobutton"),
    vScrollbar   = Style("Vertical.Scrollbar"),
    hScrollbar   = Style("Horizontal.Scrollbar"),
    separator    = Style("TSeparator"),
    vSlider      = Style("Vertical.Scale"),
    hSlider      = Style("Horizontal.Scale"),
    spinbox      = Style("TSpinbox"),
    text         = Style(""),
    toolButton   = Style("Toolbutton"),
    tree         = Style("Treeview"),
    window       = Style(""),
}

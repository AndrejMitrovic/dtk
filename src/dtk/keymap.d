/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.keymap;

import dtk.imports;

/**
    All possible key codes recognized by DTK.

    Note: This can't be an enum KeySym due tue linking issues.
    See Issue 10942:
    http://d.puremagic.com/issues/show_bug.cgi?id=10942
*/
struct KeySym
{
    long value;
    alias value this;

    this(long value)
    {
        this.value = value;
    }

    __gshared string[long] keySymToName;

    shared static this()
    {
        foreach (member; __traits(allMembers, KeySym))
        static if (is(typeof(mixin(member)) == KeySym))
        {
            keySymToName[mixin(member)] = member;
        }
    }

    // workaround for pretty printing
    string toString() const
    {
        if (value == typeof(value).init)
            return "";

        return keySymToName[value];
    }

    /** Todo: these should all be lowercase. */

    enum KeySym VoidSymbol               = 0xFFFFFF;        /* void symbol */

        // #ifdef MISCELLANY
        /*
         * TTY Functions, cleverly chosen to map to ascii, for convenience of
         * programming, but could have been arbitrary (at the cost of lookup
         * tables in client code.
         */

    enum KeySym BackSpace                = 0xFF08;  /* back space, back char */
    enum KeySym Tab                      = 0xFF09;
    enum KeySym Linefeed                 = 0xFF0A;  /* Linefeed, LF */
    enum KeySym Clear                    = 0xFF0B;
    enum KeySym Return                   = 0xFF0D;  /* Return, enter */
    enum KeySym Pause                    = 0xFF13;  /* Pause, hold */
    enum KeySym Scroll_Lock              = 0xFF14;
    enum KeySym Sys_Req                  = 0xFF15;
    enum KeySym Escape                   = 0xFF1B;
    enum KeySym Delete                   = 0xFFFF;  /* Delete, rubout */



        /* International & multi-key character composition */

    enum KeySym Multi_key                = 0xFF20;  /* Multi-key character compose */

        /* Japanese keyboard support */

    enum KeySym Kanji                    = 0xFF21;  /* Kanji, Kanji convert */
    enum KeySym Muhenkan                 = 0xFF22;  /* Cancel Conversion */
    enum KeySym Henkan_Mode              = 0xFF23;  /* Start/Stop Conversion */
    enum KeySym Henkan                   = 0xFF23;  /* Alias for Henkan_Mode */
    enum KeySym Romaji                   = 0xFF24;  /* to Romaji */
    enum KeySym Hiragana                 = 0xFF25;  /* to Hiragana */
    enum KeySym Katakana                 = 0xFF26;  /* to Katakana */
    enum KeySym Hiragana_Katakana        = 0xFF27;  /* Hiragana/Katakana toggle */
    enum KeySym Zenkaku                  = 0xFF28;  /* to Zenkaku */
    enum KeySym Hankaku                  = 0xFF29;  /* to Hankaku */
    enum KeySym Zenkaku_Hankaku          = 0xFF2A;  /* Zenkaku/Hankaku toggle */
    enum KeySym Touroku                  = 0xFF2B;  /* Add to Dictionary */
    enum KeySym Massyo                   = 0xFF2C;  /* Delete from Dictionary */
    enum KeySym Kana_Lock                = 0xFF2D;  /* Kana Lock */
    enum KeySym Kana_Shift               = 0xFF2E;  /* Kana Shift */
    enum KeySym Eisu_Shift               = 0xFF2F;  /* Alphanumeric Shift */
    enum KeySym Eisu_toggle              = 0xFF30;  /* Alphanumeric toggle */

        /* Cursor control & motion */

    enum KeySym Home                    = 0xFF50;
    enum KeySym Left                    = 0xFF51;  /* Move left, left arrow */
    enum KeySym Up                      = 0xFF52;  /* Move up, up arrow */
    enum KeySym Right                   = 0xFF53;  /* Move right, right arrow */
    enum KeySym Down                    = 0xFF54;  /* Move down, down arrow */
    enum KeySym Prior                   = 0xFF55;  /* Prior, previous */
    enum KeySym Page_Up                 = 0xFF55;
    enum KeySym Next                    = 0xFF56;  /* Next */
    enum KeySym Page_Down               = 0xFF56;
    enum KeySym End                     = 0xFF57;  /* EOL */
    enum KeySym Begin                   = 0xFF58;  /* BOL */

        /* Special Windows keyboard keys */

    enum KeySym Win_L                   = 0xFF5B;  /* Left-hand Windows */
    enum KeySym Win_R                   = 0xFF5C;  /* Right-hand Windows */
    enum KeySym App                     = 0xFF5D;  /* Menu key */

        /* Misc Functions */

    enum KeySym Select                  = 0xFF60;  /* Select, mark */
    enum KeySym Print                   = 0xFF61;
    enum KeySym Execute                 = 0xFF62;  /* Execute, run, do */
    enum KeySym Insert                  = 0xFF63;  /* Insert, insert here */
    enum KeySym Undo                    = 0xFF65;  /* Undo, oops */
    enum KeySym Redo                    = 0xFF66;  /* redo, again */
    enum KeySym Menu                    = 0xFF67;
    enum KeySym Find                    = 0xFF68;  /* Find, search */
    enum KeySym Cancel                  = 0xFF69;  /* Cancel, stop, abort, exit */
    enum KeySym Help                    = 0xFF6A;  /* Help, ? */
    enum KeySym Break                   = 0xFF6B;
    enum KeySym Mode_switch             = 0xFF7E;  /* Character set switch */
    enum KeySym script_switch           = 0xFF7E;  /* Alias for mode_switch */
    enum KeySym Num_Lock                = 0xFF7F;

        /* Keypad Functions, keypad numbers cleverly chosen to map to ascii */

    enum KeySym KP_Space                 = 0xFF80;  /* space */
    enum KeySym KP_Tab                   = 0xFF89;
    enum KeySym KP_Enter                 = 0xFF8D;  /* enter */
    enum KeySym KP_F1                    = 0xFF91;  /* PF1enum KeySym  KP_A, ... */
    enum KeySym KP_F2                    = 0xFF92;
    enum KeySym KP_F3                    = 0xFF93;
    enum KeySym KP_F4                    = 0xFF94;
    enum KeySym KP_Home                  = 0xFF95;
    enum KeySym KP_Left                  = 0xFF96;
    enum KeySym KP_Up                    = 0xFF97;
    enum KeySym KP_Right                 = 0xFF98;
    enum KeySym KP_Down                  = 0xFF99;
    enum KeySym KP_Prior                 = 0xFF9A;
    enum KeySym KP_Page_Up               = 0xFF9A;
    enum KeySym KP_Next                  = 0xFF9B;
    enum KeySym KP_Page_Down             = 0xFF9B;
    enum KeySym KP_End                   = 0xFF9C;
    enum KeySym KP_Begin                 = 0xFF9D;
    enum KeySym KP_Insert                = 0xFF9E;
    enum KeySym KP_Delete                = 0xFF9F;
    enum KeySym KP_Equal                 = 0xFFBD;  /* equals */
    enum KeySym KP_Multiply              = 0xFFAA;
    enum KeySym KP_Add                   = 0xFFAB;
    enum KeySym KP_Separator             = 0xFFAC;  /* separator, often comma */
    enum KeySym KP_Subtract              = 0xFFAD;
    enum KeySym KP_Decimal               = 0xFFAE;
    enum KeySym KP_Divide                = 0xFFAF;

    enum KeySym KP_0                     = 0xFFB0;
    enum KeySym KP_1                     = 0xFFB1;
    enum KeySym KP_2                     = 0xFFB2;
    enum KeySym KP_3                     = 0xFFB3;
    enum KeySym KP_4                     = 0xFFB4;
    enum KeySym KP_5                     = 0xFFB5;
    enum KeySym KP_6                     = 0xFFB6;
    enum KeySym KP_7                     = 0xFFB7;
    enum KeySym KP_8                     = 0xFFB8;
    enum KeySym KP_9                     = 0xFFB9;



        /*
         * Auxilliary Functions; note the duplicate definitions for left and right
         * function keys;  Sun keyboards and a few other manufactures have such
         * function key groups on the left and/or right sides of the keyboard.
         * We've not found a keyboard with more than 35 function keys total.
         */

    enum KeySym F1                       = 0xFFBE;
    enum KeySym F2                       = 0xFFBF;
    enum KeySym F3                       = 0xFFC0;
    enum KeySym F4                       = 0xFFC1;
    enum KeySym F5                       = 0xFFC2;
    enum KeySym F6                       = 0xFFC3;
    enum KeySym F7                       = 0xFFC4;
    enum KeySym F8                       = 0xFFC5;
    enum KeySym F9                       = 0xFFC6;
    enum KeySym F10                      = 0xFFC7;
    enum KeySym F11                      = 0xFFC8;
    enum KeySym L1                       = 0xFFC8;
    enum KeySym F12                      = 0xFFC9;
    enum KeySym L2                       = 0xFFC9;
    enum KeySym F13                      = 0xFFCA;
    enum KeySym L3                       = 0xFFCA;
    enum KeySym F14                      = 0xFFCB;
    enum KeySym L4                       = 0xFFCB;
    enum KeySym F15                      = 0xFFCC;
    enum KeySym L5                       = 0xFFCC;
    enum KeySym F16                      = 0xFFCD;
    enum KeySym L6                       = 0xFFCD;
    enum KeySym F17                      = 0xFFCE;
    enum KeySym L7                       = 0xFFCE;
    enum KeySym F18                      = 0xFFCF;
    enum KeySym L8                       = 0xFFCF;
    enum KeySym F19                      = 0xFFD0;
    enum KeySym L9                       = 0xFFD0;
    enum KeySym F20                      = 0xFFD1;
    enum KeySym L10                      = 0xFFD1;
    enum KeySym F21                      = 0xFFD2;
    enum KeySym R1                       = 0xFFD2;
    enum KeySym F22                      = 0xFFD3;
    enum KeySym R2                       = 0xFFD3;
    enum KeySym F23                      = 0xFFD4;
    enum KeySym R3                       = 0xFFD4;
    enum KeySym F24                      = 0xFFD5;
    enum KeySym R4                       = 0xFFD5;
    enum KeySym F25                      = 0xFFD6;
    enum KeySym R5                       = 0xFFD6;
    enum KeySym F26                      = 0xFFD7;
    enum KeySym R6                       = 0xFFD7;
    enum KeySym F27                      = 0xFFD8;
    enum KeySym R7                       = 0xFFD8;
    enum KeySym F28                      = 0xFFD9;
    enum KeySym R8                       = 0xFFD9;
    enum KeySym F29                      = 0xFFDA;
    enum KeySym R9                       = 0xFFDA;
    enum KeySym F30                      = 0xFFDB;
    enum KeySym R10                      = 0xFFDB;
    enum KeySym F31                      = 0xFFDC;
    enum KeySym R11                      = 0xFFDC;
    enum KeySym F32                      = 0xFFDD;
    enum KeySym R12                      = 0xFFDD;
    enum KeySym F33                      = 0xFFDE;
    enum KeySym R13                      = 0xFFDE;
    enum KeySym F34                      = 0xFFDF;
    enum KeySym R14                      = 0xFFDF;
    enum KeySym F35                      = 0xFFE0;
    enum KeySym R15                      = 0xFFE0;

        /* Modifiers */

    enum KeySym Shift_L                  = 0xFFE1;  /* Left shift */
    enum KeySym Shift_R                  = 0xFFE2;  /* Right shift */
    enum KeySym Control_L                = 0xFFE3;  /* Left control */
    enum KeySym Control_R                = 0xFFE4;  /* Right control */
    enum KeySym Caps_Lock                = 0xFFE5;  /* Caps lock */
    enum KeySym Shift_Lock               = 0xFFE6;  /* Shift lock */

    enum KeySym Meta_L                   = 0xFFE7;  /* Left meta */
    enum KeySym Meta_R                   = 0xFFE8;  /* Right meta */
    enum KeySym Alt_L                    = 0xFFE9;  /* Left alt */
    enum KeySym Alt_R                    = 0xFFEA;  /* Right alt */
    enum KeySym Super_L                  = 0xFFEB;  /* Left super */
    enum KeySym Super_R                  = 0xFFEC;  /* Right super */
    enum KeySym Hyper_L                  = 0xFFED;  /* Left hyper */
    enum KeySym Hyper_R                  = 0xFFEE;  /* Right hyper */
        // #endif /* MISCELLANY */

        /*
         *  Latin 1
         *  Byte 3 = 0
         */
        // #ifdef LATIN1
    enum KeySym space               = 0x020;
    enum KeySym exclam              = 0x021;
    enum KeySym quotedbl            = 0x022;
    enum KeySym numbersign          = 0x023;
    enum KeySym dollar              = 0x024;
    enum KeySym percent             = 0x025;
    enum KeySym ampersand           = 0x026;
    enum KeySym apostrophe          = 0x027;
    enum KeySym quoteright          = 0x027;        /* deprecated */
    enum KeySym parenleft           = 0x028;
    enum KeySym parenright          = 0x029;
    enum KeySym asterisk            = 0x02a;
    enum KeySym plus                = 0x02b;
    enum KeySym comma               = 0x02c;
    enum KeySym minus               = 0x02d;
    enum KeySym period              = 0x02e;
    enum KeySym slash               = 0x02f;
    enum KeySym Key0                = 0x030;
    enum KeySym Key1                = 0x031;
    enum KeySym Key2                = 0x032;
    enum KeySym Key3                = 0x033;
    enum KeySym Key4                = 0x034;
    enum KeySym Key5                = 0x035;
    enum KeySym Key6                = 0x036;
    enum KeySym Key7                = 0x037;
    enum KeySym Key8                = 0x038;
    enum KeySym Key9                = 0x039;
    enum KeySym colon               = 0x03a;
    enum KeySym semicolon           = 0x03b;
    enum KeySym less                = 0x03c;
    enum KeySym equal               = 0x03d;
    enum KeySym greater             = 0x03e;
    enum KeySym question            = 0x03f;
    enum KeySym at                  = 0x040;
    enum KeySym A                   = 0x041;
    enum KeySym B                   = 0x042;
    enum KeySym C                   = 0x043;
    enum KeySym D                   = 0x044;
    enum KeySym E                   = 0x045;
    enum KeySym F                   = 0x046;
    enum KeySym G                   = 0x047;
    enum KeySym H                   = 0x048;
    enum KeySym I                   = 0x049;
    enum KeySym J                   = 0x04a;
    enum KeySym K                   = 0x04b;
    enum KeySym L                   = 0x04c;
    enum KeySym M                   = 0x04d;
    enum KeySym N                   = 0x04e;
    enum KeySym O                   = 0x04f;
    enum KeySym P                   = 0x050;
    enum KeySym Q                   = 0x051;
    enum KeySym R                   = 0x052;
    enum KeySym S                   = 0x053;
    enum KeySym T                   = 0x054;
    enum KeySym U                   = 0x055;
    enum KeySym V                   = 0x056;
    enum KeySym W                   = 0x057;
    enum KeySym X                   = 0x058;
    enum KeySym Y                   = 0x059;
    enum KeySym Z                   = 0x05a;
    enum KeySym bracketleft         = 0x05b;
    enum KeySym backslash           = 0x05c;
    enum KeySym bracketright        = 0x05d;
    enum KeySym asciicircum         = 0x05e;
    enum KeySym underscore          = 0x05f;
    enum KeySym grave               = 0x060;
    enum KeySym quoteleft           = 0x060;        /* deprecated */
    enum KeySym a                   = 0x061;
    enum KeySym b                   = 0x062;
    enum KeySym c                   = 0x063;
    enum KeySym d                   = 0x064;
    enum KeySym e                   = 0x065;
    enum KeySym f                   = 0x066;
    enum KeySym g                   = 0x067;
    enum KeySym h                   = 0x068;
    enum KeySym i                   = 0x069;
    enum KeySym j                   = 0x06a;
    enum KeySym k                   = 0x06b;
    enum KeySym l                   = 0x06c;
    enum KeySym m                   = 0x06d;
    enum KeySym n                   = 0x06e;
    enum KeySym o                   = 0x06f;
    enum KeySym p                   = 0x070;
    enum KeySym q                   = 0x071;
    enum KeySym r                   = 0x072;
    enum KeySym s                   = 0x073;
    enum KeySym t                   = 0x074;
    enum KeySym u                   = 0x075;
    enum KeySym v                   = 0x076;
    enum KeySym w                   = 0x077;
    enum KeySym x                   = 0x078;
    enum KeySym y                   = 0x079;
    enum KeySym z                   = 0x07a;
    enum KeySym braceleft           = 0x07b;
    enum KeySym bar                 = 0x07c;
    enum KeySym braceright          = 0x07d;
    enum KeySym asciitilde          = 0x07e;

    enum KeySym nobreakspace        = 0x0a0;
    enum KeySym exclamdown          = 0x0a1;
    enum KeySym key_cent            = 0x0a2;
    enum KeySym sterling            = 0x0a3;
    enum KeySym currency            = 0x0a4;
    enum KeySym yen                 = 0x0a5;
    enum KeySym brokenbar           = 0x0a6;
    enum KeySym section             = 0x0a7;
    enum KeySym diaeresis           = 0x0a8;
    enum KeySym copyright           = 0x0a9;
    enum KeySym ordfeminine         = 0x0aa;
    enum KeySym guillemotleft       = 0x0ab;        /* left angle quotation mark */
    enum KeySym notsign             = 0x0ac;
    enum KeySym hyphen              = 0x0ad;
    enum KeySym registered          = 0x0ae;
    enum KeySym macron              = 0x0af;
    enum KeySym degree              = 0x0b0;
    enum KeySym plusminus           = 0x0b1;
    enum KeySym twosuperior         = 0x0b2;
    enum KeySym threesuperior       = 0x0b3;
    enum KeySym acute               = 0x0b4;
    enum KeySym mu                  = 0x0b5;
    enum KeySym paragraph           = 0x0b6;
    enum KeySym periodcentered      = 0x0b7;
    enum KeySym cedilla             = 0x0b8;
    enum KeySym onesuperior         = 0x0b9;
    enum KeySym masculine           = 0x0ba;
    enum KeySym guillemotright      = 0x0bb;        /* right angle quotation mark */
    enum KeySym onequarter          = 0x0bc;
    enum KeySym onehalf             = 0x0bd;
    enum KeySym threequarters       = 0x0be;
    enum KeySym questiondown        = 0x0bf;
    enum KeySym Agrave              = 0x0c0;
    enum KeySym Aacute              = 0x0c1;
    enum KeySym Acircumflex         = 0x0c2;
    enum KeySym Atilde              = 0x0c3;
    enum KeySym Adiaeresis          = 0x0c4;
    enum KeySym Aring               = 0x0c5;
    enum KeySym AE                  = 0x0c6;
    enum KeySym Ccedilla            = 0x0c7;
    enum KeySym Egrave              = 0x0c8;
    enum KeySym Eacute              = 0x0c9;
    enum KeySym Ecircumflex         = 0x0ca;
    enum KeySym Ediaeresis          = 0x0cb;
    enum KeySym Igrave              = 0x0cc;
    enum KeySym Iacute              = 0x0cd;
    enum KeySym Icircumflex         = 0x0ce;
    enum KeySym Idiaeresis          = 0x0cf;
    enum KeySym ETH                 = 0x0d0;
    enum KeySym Eth                 = 0x0d0;        /* deprecated */
    enum KeySym Ntilde              = 0x0d1;
    enum KeySym Ograve              = 0x0d2;
    enum KeySym Oacute              = 0x0d3;
    enum KeySym Ocircumflex         = 0x0d4;
    enum KeySym Otilde              = 0x0d5;
    enum KeySym Odiaeresis          = 0x0d6;
    enum KeySym multiply            = 0x0d7;
    enum KeySym Ooblique            = 0x0d8;
    enum KeySym Ugrave              = 0x0d9;
    enum KeySym Uacute              = 0x0da;
    enum KeySym Ucircumflex         = 0x0db;
    enum KeySym Udiaeresis          = 0x0dc;
    enum KeySym Yacute              = 0x0dd;
    enum KeySym THORN               = 0x0de;
    enum KeySym Thorn               = 0x0de;        /* deprecated */
    enum KeySym ssharp              = 0x0df;
    enum KeySym agrave              = 0x0e0;
    enum KeySym aacute              = 0x0e1;
    enum KeySym acircumflex         = 0x0e2;
    enum KeySym atilde              = 0x0e3;
    enum KeySym adiaeresis          = 0x0e4;
    enum KeySym aring               = 0x0e5;
    enum KeySym ae                  = 0x0e6;
    enum KeySym ccedilla            = 0x0e7;
    enum KeySym egrave              = 0x0e8;
    enum KeySym eacute              = 0x0e9;
    enum KeySym ecircumflex         = 0x0ea;
    enum KeySym ediaeresis          = 0x0eb;
    enum KeySym igrave              = 0x0ec;
    enum KeySym iacute              = 0x0ed;
    enum KeySym icircumflex         = 0x0ee;
    enum KeySym idiaeresis          = 0x0ef;
    enum KeySym eth                 = 0x0f0;
    enum KeySym ntilde              = 0x0f1;
    enum KeySym ograve              = 0x0f2;
    enum KeySym oacute              = 0x0f3;
    enum KeySym ocircumflex         = 0x0f4;
    enum KeySym otilde              = 0x0f5;
    enum KeySym odiaeresis          = 0x0f6;
    enum KeySym division            = 0x0f7;
    enum KeySym oslash              = 0x0f8;
    enum KeySym ugrave              = 0x0f9;
    enum KeySym uacute              = 0x0fa;
    enum KeySym ucircumflex         = 0x0fb;
    enum KeySym udiaeresis          = 0x0fc;
    enum KeySym yacute              = 0x0fd;
    enum KeySym thorn               = 0x0fe;
    enum KeySym ydiaeresis          = 0x0ff;
        // #endif /* LATIN1 */

        /*
         *   Latin 2
         *   Byte 3 = 1
         */

        // #ifdef LATIN2
    enum KeySym Aogonek             = 0x1a1;
    enum KeySym breve               = 0x1a2;
    enum KeySym Lstroke             = 0x1a3;
    enum KeySym Lcaron              = 0x1a5;
    enum KeySym Sacute              = 0x1a6;
    enum KeySym Scaron              = 0x1a9;
    enum KeySym Scedilla            = 0x1aa;
    enum KeySym Tcaron              = 0x1ab;
    enum KeySym Zacute              = 0x1ac;
    enum KeySym Zcaron              = 0x1ae;
    enum KeySym Zabovedot           = 0x1af;
    enum KeySym aogonek             = 0x1b1;
    enum KeySym ogonek              = 0x1b2;
    enum KeySym lstroke             = 0x1b3;
    enum KeySym lcaron              = 0x1b5;
    enum KeySym sacute              = 0x1b6;
    enum KeySym caron               = 0x1b7;
    enum KeySym scaron              = 0x1b9;
    enum KeySym scedilla            = 0x1ba;
    enum KeySym tcaron              = 0x1bb;
    enum KeySym zacute              = 0x1bc;
    enum KeySym doubleacute         = 0x1bd;
    enum KeySym zcaron              = 0x1be;
    enum KeySym zabovedot           = 0x1bf;
    enum KeySym Racute              = 0x1c0;
    enum KeySym Abreve              = 0x1c3;
    enum KeySym Lacute              = 0x1c5;
    enum KeySym Cacute              = 0x1c6;
    enum KeySym Ccaron              = 0x1c8;
    enum KeySym Eogonek             = 0x1ca;
    enum KeySym Ecaron              = 0x1cc;
    enum KeySym Dcaron              = 0x1cf;
    enum KeySym Dstroke             = 0x1d0;
    enum KeySym Nacute              = 0x1d1;
    enum KeySym Ncaron              = 0x1d2;
    enum KeySym Odoubleacute        = 0x1d5;
    enum KeySym Rcaron              = 0x1d8;
    enum KeySym Uring               = 0x1d9;
    enum KeySym Udoubleacute        = 0x1db;
    enum KeySym Tcedilla            = 0x1de;
    enum KeySym racute              = 0x1e0;
    enum KeySym abreve              = 0x1e3;
    enum KeySym lacute              = 0x1e5;
    enum KeySym cacute              = 0x1e6;
    enum KeySym ccaron              = 0x1e8;
    enum KeySym eogonek             = 0x1ea;
    enum KeySym ecaron              = 0x1ec;
    enum KeySym dcaron              = 0x1ef;
    enum KeySym dstroke             = 0x1f0;
    enum KeySym nacute              = 0x1f1;
    enum KeySym ncaron              = 0x1f2;
    enum KeySym odoubleacute        = 0x1f5;
    enum KeySym udoubleacute        = 0x1fb;
    enum KeySym rcaron              = 0x1f8;
    enum KeySym uring               = 0x1f9;
    enum KeySym tcedilla            = 0x1fe;
    enum KeySym abovedot            = 0x1ff;
        // #endif /* LATIN2 */

        /*
         *   Latin 3
         *   Byte 3 = 2
         */

        // #ifdef LATIN3
    enum KeySym Hstroke             = 0x2a1;
    enum KeySym Hcircumflex         = 0x2a6;
    enum KeySym Iabovedot           = 0x2a9;
    enum KeySym Gbreve              = 0x2ab;
    enum KeySym Jcircumflex         = 0x2ac;
    enum KeySym hstroke             = 0x2b1;
    enum KeySym hcircumflex         = 0x2b6;
    enum KeySym idotless            = 0x2b9;
    enum KeySym gbreve              = 0x2bb;
    enum KeySym jcircumflex         = 0x2bc;
    enum KeySym Cabovedot           = 0x2c5;
    enum KeySym Ccircumflex         = 0x2c6;
    enum KeySym Gabovedot           = 0x2d5;
    enum KeySym Gcircumflex         = 0x2d8;
    enum KeySym Ubreve              = 0x2dd;
    enum KeySym Scircumflex         = 0x2de;
    enum KeySym cabovedot           = 0x2e5;
    enum KeySym ccircumflex         = 0x2e6;
    enum KeySym gabovedot           = 0x2f5;
    enum KeySym gcircumflex         = 0x2f8;
    enum KeySym ubreve              = 0x2fd;
    enum KeySym scircumflex         = 0x2fe;
        // #endif /* LATIN3 */


        /*
         *   Latin 4
         *   Byte 3 = 3
         */

        // #ifdef LATIN4
    enum KeySym kra                 = 0x3a2;
    enum KeySym kappa               = 0x3a2;        /* deprecated */
    enum KeySym Rcedilla            = 0x3a3;
    enum KeySym Itilde              = 0x3a5;
    enum KeySym Lcedilla            = 0x3a6;
    enum KeySym Emacron             = 0x3aa;
    enum KeySym Gcedilla            = 0x3ab;
    enum KeySym Tslash              = 0x3ac;
    enum KeySym rcedilla            = 0x3b3;
    enum KeySym itilde              = 0x3b5;
    enum KeySym lcedilla            = 0x3b6;
    enum KeySym emacron             = 0x3ba;
    enum KeySym gcedilla            = 0x3bb;
    enum KeySym tslash              = 0x3bc;
    enum KeySym ENG                 = 0x3bd;
    enum KeySym eng                 = 0x3bf;
    enum KeySym Amacron             = 0x3c0;
    enum KeySym Iogonek             = 0x3c7;
    enum KeySym Eabovedot           = 0x3cc;
    enum KeySym Imacron             = 0x3cf;
    enum KeySym Ncedilla            = 0x3d1;
    enum KeySym Omacron             = 0x3d2;
    enum KeySym Kcedilla            = 0x3d3;
    enum KeySym Uogonek             = 0x3d9;
    enum KeySym Utilde              = 0x3dd;
    enum KeySym Umacron             = 0x3de;
    enum KeySym amacron             = 0x3e0;
    enum KeySym iogonek             = 0x3e7;
    enum KeySym eabovedot           = 0x3ec;
    enum KeySym imacron             = 0x3ef;
    enum KeySym ncedilla            = 0x3f1;
    enum KeySym omacron             = 0x3f2;
    enum KeySym kcedilla            = 0x3f3;
    enum KeySym uogonek             = 0x3f9;
    enum KeySym utilde              = 0x3fd;
    enum KeySym umacron             = 0x3fe;
        // #endif /* LATIN4 */

        /*
         * Katakana
         * Byte 3 = 4
         */

        // #ifdef KATAKANA
    enum KeySym overline            = 0x47e;
    enum KeySym kana_fullstop       = 0x4a1;
    enum KeySym kana_openingbracket = 0x4a2;
    enum KeySym kana_closingbracket = 0x4a3;
    enum KeySym kana_comma          = 0x4a4;
    enum KeySym kana_conjunctive    = 0x4a5;
    enum KeySym kana_middledot      = 0x4a5;  /* deprecated */
    enum KeySym kana_WO             = 0x4a6;
    enum KeySym kana_a              = 0x4a7;
    enum KeySym kana_i              = 0x4a8;
    enum KeySym kana_u              = 0x4a9;
    enum KeySym kana_e              = 0x4aa;
    enum KeySym kana_o              = 0x4ab;
    enum KeySym kana_ya             = 0x4ac;
    enum KeySym kana_yu             = 0x4ad;
    enum KeySym kana_yo             = 0x4ae;
    enum KeySym kana_tsu            = 0x4af;
    enum KeySym kana_tu             = 0x4af;  /* deprecated */
    enum KeySym prolongedsound      = 0x4b0;
    enum KeySym kana_A              = 0x4b1;
    enum KeySym kana_I              = 0x4b2;
    enum KeySym kana_U              = 0x4b3;
    enum KeySym kana_E              = 0x4b4;
    enum KeySym kana_O              = 0x4b5;
    enum KeySym kana_KA             = 0x4b6;
    enum KeySym kana_KI             = 0x4b7;
    enum KeySym kana_KU             = 0x4b8;
    enum KeySym kana_KE             = 0x4b9;
    enum KeySym kana_KO             = 0x4ba;
    enum KeySym kana_SA             = 0x4bb;
    enum KeySym kana_SHI            = 0x4bc;
    enum KeySym kana_SU             = 0x4bd;
    enum KeySym kana_SE             = 0x4be;
    enum KeySym kana_SO             = 0x4bf;
    enum KeySym kana_TA             = 0x4c0;
    enum KeySym kana_CHI            = 0x4c1;
    enum KeySym kana_TI             = 0x4c1;  /* deprecated */
    enum KeySym kana_TSU            = 0x4c2;
    enum KeySym kana_TU             = 0x4c2;  /* deprecated */
    enum KeySym kana_TE             = 0x4c3;
    enum KeySym kana_TO             = 0x4c4;
    enum KeySym kana_NA             = 0x4c5;
    enum KeySym kana_NI             = 0x4c6;
    enum KeySym kana_NU             = 0x4c7;
    enum KeySym kana_NE             = 0x4c8;
    enum KeySym kana_NO             = 0x4c9;
    enum KeySym kana_HA             = 0x4ca;
    enum KeySym kana_HI             = 0x4cb;
    enum KeySym kana_FU             = 0x4cc;
    enum KeySym kana_HU             = 0x4cc;  /* deprecated */
    enum KeySym kana_HE             = 0x4cd;
    enum KeySym kana_HO             = 0x4ce;
    enum KeySym kana_MA             = 0x4cf;
    enum KeySym kana_MI             = 0x4d0;
    enum KeySym kana_MU             = 0x4d1;
    enum KeySym kana_ME             = 0x4d2;
    enum KeySym kana_MO             = 0x4d3;
    enum KeySym kana_YA             = 0x4d4;
    enum KeySym kana_YU             = 0x4d5;
    enum KeySym kana_YO             = 0x4d6;
    enum KeySym kana_RA             = 0x4d7;
    enum KeySym kana_RI             = 0x4d8;
    enum KeySym kana_RU             = 0x4d9;
    enum KeySym kana_RE             = 0x4da;
    enum KeySym kana_RO             = 0x4db;
    enum KeySym kana_WA             = 0x4dc;
    enum KeySym kana_N              = 0x4dd;
    enum KeySym voicedsound         = 0x4de;
    enum KeySym semivoicedsound     = 0x4df;
    enum KeySym kana_switch         = 0xFF7E;  /* Alias for mode_switch */
        // #endif /* KATAKANA */

        /*
         *  Arabic
         *  Byte 3 = 5
         */

        // #ifdef ARABIC
    enum KeySym Arabic_comma          = 0x5ac;
    enum KeySym Arabic_semicolon      = 0x5bb;
    enum KeySym Arabic_question_mark  = 0x5bf;
    enum KeySym Arabic_hamza          = 0x5c1;
    enum KeySym Arabic_maddaonalef    = 0x5c2;
    enum KeySym Arabic_hamzaonalef    = 0x5c3;
    enum KeySym Arabic_hamzaonwaw     = 0x5c4;
    enum KeySym Arabic_hamzaunderalef = 0x5c5;
    enum KeySym Arabic_hamzaonyeh     = 0x5c6;
    enum KeySym Arabic_alef           = 0x5c7;
    enum KeySym Arabic_beh            = 0x5c8;
    enum KeySym Arabic_tehmarbuta     = 0x5c9;
    enum KeySym Arabic_teh            = 0x5ca;
    enum KeySym Arabic_theh           = 0x5cb;
    enum KeySym Arabic_jeem           = 0x5cc;
    enum KeySym Arabic_hah            = 0x5cd;
    enum KeySym Arabic_khah           = 0x5ce;
    enum KeySym Arabic_dal            = 0x5cf;
    enum KeySym Arabic_thal           = 0x5d0;
    enum KeySym Arabic_ra             = 0x5d1;
    enum KeySym Arabic_zain           = 0x5d2;
    enum KeySym Arabic_seen           = 0x5d3;
    enum KeySym Arabic_sheen          = 0x5d4;
    enum KeySym Arabic_sad            = 0x5d5;
    enum KeySym Arabic_dad            = 0x5d6;
    enum KeySym Arabic_tah            = 0x5d7;
    enum KeySym Arabic_zah            = 0x5d8;
    enum KeySym Arabic_ain            = 0x5d9;
    enum KeySym Arabic_ghain          = 0x5da;
    enum KeySym Arabic_tatweel        = 0x5e0;
    enum KeySym Arabic_feh            = 0x5e1;
    enum KeySym Arabic_qaf            = 0x5e2;
    enum KeySym Arabic_kaf            = 0x5e3;
    enum KeySym Arabic_lam            = 0x5e4;
    enum KeySym Arabic_meem           = 0x5e5;
    enum KeySym Arabic_noon           = 0x5e6;
    enum KeySym Arabic_ha             = 0x5e7;
    enum KeySym Arabic_heh            = 0x5e7;  /* deprecated */
    enum KeySym Arabic_waw            = 0x5e8;
    enum KeySym Arabic_alefmaksura    = 0x5e9;
    enum KeySym Arabic_yeh            = 0x5ea;
    enum KeySym Arabic_fathatan       = 0x5eb;
    enum KeySym Arabic_dammatan       = 0x5ec;
    enum KeySym Arabic_kasratan       = 0x5ed;
    enum KeySym Arabic_fatha          = 0x5ee;
    enum KeySym Arabic_damma          = 0x5ef;
    enum KeySym Arabic_kasra          = 0x5f0;
    enum KeySym Arabic_shadda         = 0x5f1;
    enum KeySym Arabic_sukun          = 0x5f2;
    enum KeySym Arabic_switch         = 0xFF7E;  /* Alias for mode_switch */
        // #endif /* ARABIC */

        /*
         * Cyrillic
         * Byte 3 = 6
         */
        // #ifdef CYRILLIC
    enum KeySym Serbian_dje                                 = 0x6a1;
    enum KeySym Macedonia_gje                               = 0x6a2;
    enum KeySym Cyrillic_io                                 = 0x6a3;
    enum KeySym Ukrainian_ie                                = 0x6a4;
    enum KeySym Ukranian_je                                 = 0x6a4;  /* deprecated */
    enum KeySym Macedonia_dse                               = 0x6a5;
    enum KeySym Ukrainian_i                                 = 0x6a6;
    enum KeySym Ukranian_i                                  = 0x6a6;  /* deprecated */
    enum KeySym Ukrainian_yi                                = 0x6a7;
    enum KeySym Ukranian_yi                                 = 0x6a7;  /* deprecated */
    enum KeySym Cyrillic_je                                 = 0x6a8;
    enum KeySym Serbian_je                                  = 0x6a8;  /* deprecated */
    enum KeySym Cyrillic_lje                                = 0x6a9;
    enum KeySym Serbian_lje                                 = 0x6a9;  /* deprecated */
    enum KeySym Cyrillic_nje                                = 0x6aa;
    enum KeySym Serbian_nje                                 = 0x6aa;  /* deprecated */
    enum KeySym Serbian_tshe                                = 0x6ab;
    enum KeySym Macedonia_kje                               = 0x6ac;
    enum KeySym Byelorussian_shortu                         = 0x6ae;
    enum KeySym Cyrillic_dzhe                               = 0x6af;
    enum KeySym Serbian_dze                                 = 0x6af;  /* deprecated */
    enum KeySym numerosign                                  = 0x6b0;
    enum KeySym Serbian_DJE                                 = 0x6b1;
    enum KeySym Macedonia_GJE                               = 0x6b2;
    enum KeySym Cyrillic_IO                                 = 0x6b3;
    enum KeySym Ukrainian_IE                                = 0x6b4;
    enum KeySym Ukranian_JE                                 = 0x6b4;  /* deprecated */
    enum KeySym Macedonia_DSE                               = 0x6b5;
    enum KeySym Ukrainian_I                                 = 0x6b6;
    enum KeySym Ukranian_I                                  = 0x6b6;  /* deprecated */
    enum KeySym Ukrainian_YI                                = 0x6b7;
    enum KeySym Ukranian_YI                                 = 0x6b7;  /* deprecated */
    enum KeySym Cyrillic_JE                                 = 0x6b8;
    enum KeySym Serbian_JE                                  = 0x6b8;  /* deprecated */
    enum KeySym Cyrillic_LJE                                = 0x6b9;
    enum KeySym Serbian_LJE                                 = 0x6b9;  /* deprecated */
    enum KeySym Cyrillic_NJE                                = 0x6ba;
    enum KeySym Serbian_NJE                                 = 0x6ba;  /* deprecated */
    enum KeySym Serbian_TSHE                                = 0x6bb;
    enum KeySym Macedonia_KJE                               = 0x6bc;
    enum KeySym Byelorussian_SHORTU                         = 0x6be;
    enum KeySym Cyrillic_DZHE                               = 0x6bf;
    enum KeySym Serbian_DZE                                 = 0x6bf;  /* deprecated */
    enum KeySym Cyrillic_yu                                 = 0x6c0;
    enum KeySym Cyrillic_a                                  = 0x6c1;
    enum KeySym Cyrillic_be                                 = 0x6c2;
    enum KeySym Cyrillic_tse                                = 0x6c3;
    enum KeySym Cyrillic_de                                 = 0x6c4;
    enum KeySym Cyrillic_ie                                 = 0x6c5;
    enum KeySym Cyrillic_ef                                 = 0x6c6;
    enum KeySym Cyrillic_ghe                                = 0x6c7;
    enum KeySym Cyrillic_ha                                 = 0x6c8;
    enum KeySym Cyrillic_i                                  = 0x6c9;
    enum KeySym Cyrillic_shorti                             = 0x6ca;
    enum KeySym Cyrillic_ka                                 = 0x6cb;
    enum KeySym Cyrillic_el                                 = 0x6cc;
    enum KeySym Cyrillic_em                                 = 0x6cd;
    enum KeySym Cyrillic_en                                 = 0x6ce;
    enum KeySym Cyrillic_o                                  = 0x6cf;
    enum KeySym Cyrillic_pe                                 = 0x6d0;
    enum KeySym Cyrillic_ya                                 = 0x6d1;
    enum KeySym Cyrillic_er                                 = 0x6d2;
    enum KeySym Cyrillic_es                                 = 0x6d3;
    enum KeySym Cyrillic_te                                 = 0x6d4;
    enum KeySym Cyrillic_u                                  = 0x6d5;
    enum KeySym Cyrillic_zhe                                = 0x6d6;
    enum KeySym Cyrillic_ve                                 = 0x6d7;
    enum KeySym Cyrillic_softsign                           = 0x6d8;
    enum KeySym Cyrillic_yeru                               = 0x6d9;
    enum KeySym Cyrillic_ze                                 = 0x6da;
    enum KeySym Cyrillic_sha                                = 0x6db;
    enum KeySym Cyrillic_e                                  = 0x6dc;
    enum KeySym Cyrillic_shcha                              = 0x6dd;
    enum KeySym Cyrillic_che                                = 0x6de;
    enum KeySym Cyrillic_hardsign                           = 0x6df;
    enum KeySym Cyrillic_YU                                 = 0x6e0;
    enum KeySym Cyrillic_A                                  = 0x6e1;
    enum KeySym Cyrillic_BE                                 = 0x6e2;
    enum KeySym Cyrillic_TSE                                = 0x6e3;
    enum KeySym Cyrillic_DE                                 = 0x6e4;
    enum KeySym Cyrillic_IE                                 = 0x6e5;
    enum KeySym Cyrillic_EF                                 = 0x6e6;
    enum KeySym Cyrillic_GHE                                = 0x6e7;
    enum KeySym Cyrillic_HA                                 = 0x6e8;
    enum KeySym Cyrillic_I                                  = 0x6e9;
    enum KeySym Cyrillic_SHORTI                             = 0x6ea;
    enum KeySym Cyrillic_KA                                 = 0x6eb;
    enum KeySym Cyrillic_EL                                 = 0x6ec;
    enum KeySym Cyrillic_EM                                 = 0x6ed;
    enum KeySym Cyrillic_EN                                 = 0x6ee;
    enum KeySym Cyrillic_O                                  = 0x6ef;
    enum KeySym Cyrillic_PE                                 = 0x6f0;
    enum KeySym Cyrillic_YA                                 = 0x6f1;
    enum KeySym Cyrillic_ER                                 = 0x6f2;
    enum KeySym Cyrillic_ES                                 = 0x6f3;
    enum KeySym Cyrillic_TE                                 = 0x6f4;
    enum KeySym Cyrillic_U                                  = 0x6f5;
    enum KeySym Cyrillic_ZHE                                = 0x6f6;
    enum KeySym Cyrillic_VE                                 = 0x6f7;
    enum KeySym Cyrillic_SOFTSIGN                           = 0x6f8;
    enum KeySym Cyrillic_YERU                               = 0x6f9;
    enum KeySym Cyrillic_ZE                                 = 0x6fa;
    enum KeySym Cyrillic_SHA                                = 0x6fb;
    enum KeySym Cyrillic_E                                  = 0x6fc;
    enum KeySym Cyrillic_SHCHA                              = 0x6fd;
    enum KeySym Cyrillic_CHE                                = 0x6fe;
    enum KeySym Cyrillic_HARDSIGN                           = 0x6ff;
        // #endif /* CYRILLIC */

        /*
         * Greek
         * Byte 3 = 7
         */

        // #ifdef GREEK
    enum KeySym Greek_ALPHAaccent                           = 0x7a1;
    enum KeySym Greek_EPSILONaccent                         = 0x7a2;
    enum KeySym Greek_ETAaccent                             = 0x7a3;
    enum KeySym Greek_IOTAaccent                            = 0x7a4;
    enum KeySym Greek_IOTAdiaeresis                         = 0x7a5;
    enum KeySym Greek_OMICRONaccent                         = 0x7a7;
    enum KeySym Greek_UPSILONaccent                         = 0x7a8;
    enum KeySym Greek_UPSILONdieresis                       = 0x7a9;
    enum KeySym Greek_OMEGAaccent                           = 0x7ab;
    enum KeySym Greek_accentdieresis                        = 0x7ae;
    enum KeySym Greek_horizbar                              = 0x7af;
    enum KeySym Greek_alphaaccent                           = 0x7b1;
    enum KeySym Greek_epsilonaccent                         = 0x7b2;
    enum KeySym Greek_etaaccent                             = 0x7b3;
    enum KeySym Greek_iotaaccent                            = 0x7b4;
    enum KeySym Greek_iotadieresis                          = 0x7b5;
    enum KeySym Greek_iotaaccentdieresis                    = 0x7b6;
    enum KeySym Greek_omicronaccent                         = 0x7b7;
    enum KeySym Greek_upsilonaccent                         = 0x7b8;
    enum KeySym Greek_upsilondieresis                       = 0x7b9;
    enum KeySym Greek_upsilonaccentdieresis                 = 0x7ba;
    enum KeySym Greek_omegaaccent                           = 0x7bb;
    enum KeySym Greek_ALPHA                                 = 0x7c1;
    enum KeySym Greek_BETA                                  = 0x7c2;
    enum KeySym Greek_GAMMA                                 = 0x7c3;
    enum KeySym Greek_DELTA                                 = 0x7c4;
    enum KeySym Greek_EPSILON                               = 0x7c5;
    enum KeySym Greek_ZETA                                  = 0x7c6;
    enum KeySym Greek_ETA                                   = 0x7c7;
    enum KeySym Greek_THETA                                 = 0x7c8;
    enum KeySym Greek_IOTA                                  = 0x7c9;
    enum KeySym Greek_KAPPA                                 = 0x7ca;
    enum KeySym Greek_LAMDA                                 = 0x7cb;
    enum KeySym Greek_LAMBDA                                = 0x7cb;
    enum KeySym Greek_MU                                    = 0x7cc;
    enum KeySym Greek_NU                                    = 0x7cd;
    enum KeySym Greek_XI                                    = 0x7ce;
    enum KeySym Greek_OMICRON                               = 0x7cf;
    enum KeySym Greek_PI                                    = 0x7d0;
    enum KeySym Greek_RHO                                   = 0x7d1;
    enum KeySym Greek_SIGMA                                 = 0x7d2;
    enum KeySym Greek_TAU                                   = 0x7d4;
    enum KeySym Greek_UPSILON                               = 0x7d5;
    enum KeySym Greek_PHI                                   = 0x7d6;
    enum KeySym Greek_CHI                                   = 0x7d7;
    enum KeySym Greek_PSI                                   = 0x7d8;
    enum KeySym Greek_OMEGA                                 = 0x7d9;
    enum KeySym Greek_alpha                                 = 0x7e1;
    enum KeySym Greek_beta                                  = 0x7e2;
    enum KeySym Greek_gamma                                 = 0x7e3;
    enum KeySym Greek_delta                                 = 0x7e4;
    enum KeySym Greek_epsilon                               = 0x7e5;
    enum KeySym Greek_zeta                                  = 0x7e6;
    enum KeySym Greek_eta                                   = 0x7e7;
    enum KeySym Greek_theta                                 = 0x7e8;
    enum KeySym Greek_iota                                  = 0x7e9;
    enum KeySym Greek_kappa                                 = 0x7ea;
    enum KeySym Greek_lamda                                 = 0x7eb;
    enum KeySym Greek_lambda                                = 0x7eb;
    enum KeySym Greek_mu                                    = 0x7ec;
    enum KeySym Greek_nu                                    = 0x7ed;
    enum KeySym Greek_xi                                    = 0x7ee;
    enum KeySym Greek_omicron                               = 0x7ef;
    enum KeySym Greek_pi                                    = 0x7f0;
    enum KeySym Greek_rho                                   = 0x7f1;
    enum KeySym Greek_sigma                                 = 0x7f2;
    enum KeySym Greek_finalsmallsigma                       = 0x7f3;
    enum KeySym Greek_tau                                   = 0x7f4;
    enum KeySym Greek_upsilon                               = 0x7f5;
    enum KeySym Greek_phi                                   = 0x7f6;
    enum KeySym Greek_chi                                   = 0x7f7;
    enum KeySym Greek_psi                                   = 0x7f8;
    enum KeySym Greek_omega                                 = 0x7f9;
    enum KeySym Greek_switch                                = 0xFF7E;  /* Alias for mode_switch */
        // #endif /* GREEK */

        /*
         * Technical
         * Byte 3 = 8
         */

        // #ifdef TECHNICAL
    enum KeySym leftradical                                 = 0x8a1;
    enum KeySym topleftradical                              = 0x8a2;
    enum KeySym horizconnector                              = 0x8a3;
    enum KeySym topintegral                                 = 0x8a4;
    enum KeySym botintegral                                 = 0x8a5;
    enum KeySym vertconnector                               = 0x8a6;
    enum KeySym topleftsqbracket                            = 0x8a7;
    enum KeySym botleftsqbracket                            = 0x8a8;
    enum KeySym toprightsqbracket                           = 0x8a9;
    enum KeySym botrightsqbracket                           = 0x8aa;
    enum KeySym topleftparens                               = 0x8ab;
    enum KeySym botleftparens                               = 0x8ac;
    enum KeySym toprightparens                              = 0x8ad;
    enum KeySym botrightparens                              = 0x8ae;
    enum KeySym leftmiddlecurlybrace                        = 0x8af;
    enum KeySym rightmiddlecurlybrace                       = 0x8b0;
    enum KeySym topleftsummation                            = 0x8b1;
    enum KeySym botleftsummation                            = 0x8b2;
    enum KeySym topvertsummationconnector                   = 0x8b3;
    enum KeySym botvertsummationconnector                   = 0x8b4;
    enum KeySym toprightsummation                           = 0x8b5;
    enum KeySym botrightsummation                           = 0x8b6;
    enum KeySym rightmiddlesummation                        = 0x8b7;
    enum KeySym lessthanequal                               = 0x8bc;
    enum KeySym notequal                                    = 0x8bd;
    enum KeySym greaterthanequal                            = 0x8be;
    enum KeySym integral                                    = 0x8bf;
    enum KeySym therefore                                   = 0x8c0;
    enum KeySym variation                                   = 0x8c1;
    enum KeySym infinity                                    = 0x8c2;
    enum KeySym nabla                                       = 0x8c5;
    enum KeySym approximate                                 = 0x8c8;
    enum KeySym similarequal                                = 0x8c9;
    enum KeySym ifonlyif                                    = 0x8cd;
    enum KeySym implies                                     = 0x8ce;
    enum KeySym identical                                   = 0x8cf;
    enum KeySym radical                                     = 0x8d6;
    enum KeySym includedin                                  = 0x8da;
    enum KeySym includes                                    = 0x8db;
    enum KeySym intersection                                = 0x8dc;
    enum KeySym key_union                                   = 0x8dd;
    enum KeySym logicaland                                  = 0x8de;
    enum KeySym logicalor                                   = 0x8df;
    enum KeySym partialderivative                           = 0x8ef;
    enum KeySym key_function                                = 0x8f6;
    enum KeySym leftarrow                                   = 0x8fb;
    enum KeySym uparrow                                     = 0x8fc;
    enum KeySym rightarrow                                  = 0x8fd;
    enum KeySym downarrow                                   = 0x8fe;
        // #endif /* TECHNICAL */

        /*
         *  Special
         *  Byte 3 = 9
         */

        // #ifdef SPECIAL
    enum KeySym blank                                       = 0x9df;
    enum KeySym soliddiamond                                = 0x9e0;
    enum KeySym checkerboard                                = 0x9e1;
    enum KeySym ht                                          = 0x9e2;
    enum KeySym ff                                          = 0x9e3;
    enum KeySym cr                                          = 0x9e4;
    enum KeySym lf                                          = 0x9e5;
    enum KeySym nl                                          = 0x9e8;
    enum KeySym vt                                          = 0x9e9;
    enum KeySym lowrightcorner                              = 0x9ea;
    enum KeySym uprightcorner                               = 0x9eb;
    enum KeySym upleftcorner                                = 0x9ec;
    enum KeySym lowleftcorner                               = 0x9ed;
    enum KeySym crossinglines                               = 0x9ee;
    enum KeySym horizlinescan1                              = 0x9ef;
    enum KeySym horizlinescan3                              = 0x9f0;
    enum KeySym horizlinescan5                              = 0x9f1;
    enum KeySym horizlinescan7                              = 0x9f2;
    enum KeySym horizlinescan9                              = 0x9f3;
    enum KeySym leftt                                       = 0x9f4;
    enum KeySym rightt                                      = 0x9f5;
    enum KeySym bott                                        = 0x9f6;
    enum KeySym topt                                        = 0x9f7;
    enum KeySym vertbar                                     = 0x9f8;
        // #endif /* SPECIAL */

        /*
         *  Publishing
         *  Byte 3 = a
             */

    //#ifdef PUBLISHING
    enum KeySym emspace                                     = 0xaa1;
    enum KeySym enspace                                     = 0xaa2;
    enum KeySym em3space                                    = 0xaa3;
    enum KeySym em4space                                    = 0xaa4;
    enum KeySym digitspace                                  = 0xaa5;
    enum KeySym punctspace                                  = 0xaa6;
    enum KeySym thinspace                                   = 0xaa7;
    enum KeySym hairspace                                   = 0xaa8;
    enum KeySym emdash                                      = 0xaa9;
    enum KeySym endash                                      = 0xaaa;
    enum KeySym signifblank                                 = 0xaac;
    enum KeySym ellipsis                                    = 0xaae;
    enum KeySym doubbaselinedot                             = 0xaaf;
    enum KeySym onethird                                    = 0xab0;
    enum KeySym twothirds                                   = 0xab1;
    enum KeySym onefifth                                    = 0xab2;
    enum KeySym twofifths                                   = 0xab3;
    enum KeySym threefifths                                 = 0xab4;
    enum KeySym fourfifths                                  = 0xab5;
    enum KeySym onesixth                                    = 0xab6;
    enum KeySym fivesixths                                  = 0xab7;
    enum KeySym careof                                      = 0xab8;
    enum KeySym figdash                                     = 0xabb;
    enum KeySym leftanglebracket                            = 0xabc;
    enum KeySym decimalpoint                                = 0xabd;
    enum KeySym rightanglebracket                           = 0xabe;
    enum KeySym marker                                      = 0xabf;
    enum KeySym oneeighth                                   = 0xac3;
    enum KeySym threeeighths                                = 0xac4;
    enum KeySym fiveeighths                                 = 0xac5;
    enum KeySym seveneighths                                = 0xac6;
    enum KeySym trademark                                   = 0xac9;
    enum KeySym signaturemark                               = 0xaca;
    enum KeySym trademarkincircle                           = 0xacb;
    enum KeySym leftopentriangle                            = 0xacc;
    enum KeySym rightopentriangle                           = 0xacd;
    enum KeySym emopencircle                                = 0xace;
    enum KeySym emopenrectangle                             = 0xacf;
    enum KeySym leftsinglequotemark                         = 0xad0;
    enum KeySym rightsinglequotemark                        = 0xad1;
    enum KeySym leftdoublequotemark                         = 0xad2;
    enum KeySym rightdoublequotemark                        = 0xad3;
    enum KeySym prescription                                = 0xad4;
    enum KeySym minutes                                     = 0xad6;
    enum KeySym seconds                                     = 0xad7;
    enum KeySym latincross                                  = 0xad9;
    enum KeySym hexagram                                    = 0xada;
    enum KeySym filledrectbullet                            = 0xadb;
    enum KeySym filledlefttribullet                         = 0xadc;
    enum KeySym filledrighttribullet                        = 0xadd;
    enum KeySym emfilledcircle                              = 0xade;
    enum KeySym emfilledrect                                = 0xadf;
    enum KeySym enopencircbullet                            = 0xae0;
    enum KeySym enopensquarebullet                          = 0xae1;
    enum KeySym openrectbullet                              = 0xae2;
    enum KeySym opentribulletup                             = 0xae3;
    enum KeySym opentribulletdown                           = 0xae4;
    enum KeySym openstar                                    = 0xae5;
    enum KeySym enfilledcircbullet                          = 0xae6;
    enum KeySym enfilledsqbullet                            = 0xae7;
    enum KeySym filledtribulletup                           = 0xae8;
    enum KeySym filledtribulletdown                         = 0xae9;
    enum KeySym leftpointer                                 = 0xaea;
    enum KeySym rightpointer                                = 0xaeb;
    enum KeySym club                                        = 0xaec;
    enum KeySym diamond                                     = 0xaed;
    enum KeySym heart                                       = 0xaee;
    enum KeySym maltesecross                                = 0xaf0;
    enum KeySym dagger                                      = 0xaf1;
    enum KeySym doubledagger                                = 0xaf2;
    enum KeySym checkmark                                   = 0xaf3;
    enum KeySym ballotcross                                 = 0xaf4;
    enum KeySym musicalsharp                                = 0xaf5;
    enum KeySym musicalflat                                 = 0xaf6;
    enum KeySym malesymbol                                  = 0xaf7;
    enum KeySym femalesymbol                                = 0xaf8;
    enum KeySym telephone                                   = 0xaf9;
    enum KeySym telephonerecorder                           = 0xafa;
    enum KeySym phonographcopyright                         = 0xafb;
    enum KeySym caret                                       = 0xafc;
    enum KeySym singlelowquotemark                          = 0xafd;
    enum KeySym doublelowquotemark                          = 0xafe;
    enum KeySym cursor                                      = 0xaff;
    // #endif /* PUBLISHING */

    /*
     *  APL
     *  Byte 3 = b
     */

    // #ifdef APL
    enum KeySym leftcaret                                   = 0xba3;
    enum KeySym rightcaret                                  = 0xba6;
    enum KeySym downcaret                                   = 0xba8;
    enum KeySym upcaret                                     = 0xba9;
    enum KeySym overbar                                     = 0xbc0;
    enum KeySym downtack                                    = 0xbc2;
    enum KeySym upshoe                                      = 0xbc3;
    enum KeySym downstile                                   = 0xbc4;
    enum KeySym underbar                                    = 0xbc6;
    enum KeySym jot                                         = 0xbca;
    enum KeySym quad                                        = 0xbcc;
    enum KeySym uptack                                      = 0xbce;
    enum KeySym circle                                      = 0xbcf;
    enum KeySym upstile                                     = 0xbd3;
    enum KeySym downshoe                                    = 0xbd6;
    enum KeySym rightshoe                                   = 0xbd8;
    enum KeySym leftshoe                                    = 0xbda;
    enum KeySym lefttack                                    = 0xbdc;
    enum KeySym righttack                                   = 0xbfc;
    // #endif /* APL */

    /*
     * Hebrew
     * Byte 3 = c
     */

    // #ifdef HEBREW
    enum KeySym hebrew_doublelowline                        = 0xcdf;
    enum KeySym hebrew_aleph                                = 0xce0;
    enum KeySym hebrew_bet                                  = 0xce1;
    enum KeySym hebrew_beth                                 = 0xce1;  /* deprecated */
    enum KeySym hebrew_gimel                                = 0xce2;
    enum KeySym hebrew_gimmel                               = 0xce2;  /* deprecated */
    enum KeySym hebrew_dalet                                = 0xce3;
    enum KeySym hebrew_daleth                               = 0xce3;  /* deprecated */
    enum KeySym hebrew_he                                   = 0xce4;
    enum KeySym hebrew_waw                                  = 0xce5;
    enum KeySym hebrew_zain                                 = 0xce6;
    enum KeySym hebrew_zayin                                = 0xce6;  /* deprecated */
    enum KeySym hebrew_chet                                 = 0xce7;
    enum KeySym hebrew_het                                  = 0xce7;  /* deprecated */
    enum KeySym hebrew_tet                                  = 0xce8;
    enum KeySym hebrew_teth                                 = 0xce8;  /* deprecated */
    enum KeySym hebrew_yod                                  = 0xce9;
    enum KeySym hebrew_finalkaph                            = 0xcea;
    enum KeySym hebrew_kaph                                 = 0xceb;
    enum KeySym hebrew_lamed                                = 0xcec;
    enum KeySym hebrew_finalmem                             = 0xced;
    enum KeySym hebrew_mem                                  = 0xcee;
    enum KeySym hebrew_finalnun                             = 0xcef;
    enum KeySym hebrew_nun                                  = 0xcf0;
    enum KeySym hebrew_samech                               = 0xcf1;
    enum KeySym hebrew_samekh                               = 0xcf1;  /* deprecated */
    enum KeySym hebrew_ayin                                 = 0xcf2;
    enum KeySym hebrew_finalpe                              = 0xcf3;
    enum KeySym hebrew_pe                                   = 0xcf4;
    enum KeySym hebrew_finalzade                            = 0xcf5;
    enum KeySym hebrew_finalzadi                            = 0xcf5;  /* deprecated */
    enum KeySym hebrew_zade                                 = 0xcf6;
    enum KeySym hebrew_zadi                                 = 0xcf6;  /* deprecated */
    enum KeySym hebrew_qoph                                 = 0xcf7;
    enum KeySym hebrew_kuf                                  = 0xcf7;  /* deprecated */
    enum KeySym hebrew_resh                                 = 0xcf8;
    enum KeySym hebrew_shin                                 = 0xcf9;
    enum KeySym hebrew_taw                                  = 0xcfa;
    enum KeySym hebrew_taf                                  = 0xcfa;  /* deprecated */
    enum KeySym Hebrew_switch                               = 0xFF7E;  /* Alias for mode_switch */
    // #endif /* HEBREW */
}

unittest
{
    auto keySym = KeySym.BackSpace;
    assert(keySym.text == "BackSpace");
}

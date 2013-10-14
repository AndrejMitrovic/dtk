/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.imports;

public
{
    version (DTK_USE_PHOBOS)
    {
        import dtk.imports.phobos;
    }
    else
    {
        import dtk.imports.inline;
    }
}

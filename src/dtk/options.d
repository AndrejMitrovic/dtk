/*
 *             Copyright Andrej Mitrovic 2013.
 *  Distributed under the Boost Software License, Version 1.0.
 *     (See accompanying file LICENSE_1_0.txt or copy at
 *           http://www.boost.org/LICENSE_1_0.txt)
 */
module dtk.options;

alias Options = string[string];

// todo: we've added a \0, it seems to have missed this.
// not sure if it was buggy or not.
char[] options2string(Options opt)
{
    char[] result;

    foreach (k; opt.keys)
        result ~= "-" ~ k ~ " \"" ~ opt[k] ~ "\" ";

    return result;
}

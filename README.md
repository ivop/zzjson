Preserved from [sourceforge](https://zzjson.sourceforge.net/) at 2024-10-31  
Updated to build with modern tools. [API documentation](doc/api-1.1.md) converted to markdown.
This is an old project, but might still be useful. The parser is very small.  

==================================================================================

zzjson - Copyright (C) 2008-2012 by Ivo van Poorten

zzjson is licensed under the GNU Lesser General Public License, version 2.1.
See LICENSE file for details.

From Wikipedia:

    JSON (pronounced [..] "Jason"), short for JavaScript Object
    Notation, is a lightweight computer data interchange format. It is a
    text-based, human-readable format for representing simple data structures
    and associative arrays (called objects).

zzjson implements a small library for reading, writing, querying and
constructing JSON objects. It works through several callback functions
and is internally character encoding agnostic (i.e. it works with plain
C strings of characters). \uHHHH escapes are copied verbatim by both the
parser and the printer. Unicode input and output can be supported through
getchar and putchar callbacks that escape all non-ASCII characters [1].

If you build the test and run test.sh, you may notice that fail18 does not
fail. This is perfectly normal. fail18 tests deep nesting and I see no
reason why it should fail on such a file.


For API documentation, installation instructions  and usage, see the wiki at:

    http://sourceforge.net/projects/zzjson/



[1] After I wrote the above, I implemented a proof-of-concept unicode
    callbacks implementation. It resides in the unicode/ directory and
    example2.c uses it. It supports all unicode variants (UTF-8, UTF-16LE,
    UTF-16BE, UTF-32LE and UTF-32BE) for both input and output of .json files.
    The UNIContext structure uses callbacks for get/putchar again, so
    reading or writing of unicode json files is still not limitted to
    files only, but can be e.g. from/to memory instead, if you provide the
    right callback. If UNIContext.type is not set, the code tries to determine
    the type by interpretting a BOM at the beginning of the file. If it's
    not set and there's no BOM, it defaults to UTF-8.


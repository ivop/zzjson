/* ZZJSON - example 2 - Copyright (C) 2008 by Ivo van Poorten
 * License: GNU Lesser General Public License version 2.1
 *
 * compile with:
 *
 * gcc -Iunicode -o example2 example2.c zzjson_{parse,free,print}.c \
 *                                  unicode/unicode_callbacks.c -lm -W -Wall
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include "zzjson.h"
#include "unicode_callbacks.h"

static void myerror(void *ehandle, const char *format, ...) {
    va_list ap;
    fprintf(ehandle, "error: ");
    va_start(ap, format);
    vfprintf(ehandle, format, ap);
    va_end(ap);
    fputc('\n', ehandle);
}

int main(int argc, char **argv) {
    UNIContext unictx;
    ZZJSON *zzjson;
    ZZJSON_CONFIG config = { ZZJSON_VERY_STRICT,
                             &unictx,
                             (int(*)(void*)) unicode_getchar,
                             (int(*)(int,void*)) unicode_ungetchar,
                             malloc, calloc, free, realloc,
                             stderr, myerror,
                             stdout,
                             (int(*)(void*,const char*,...)) fprintf,
                             (int(*)(int,void*)) fputc };

    if (argc != 2) {
        fprintf(stderr, "%s: usage %s <utf-json-file>\n", argv[0], argv[0]);
        return 1;
    }

    memset(&unictx, 0, sizeof(UNIContext));
    unictx.getchar   = (int(*)(void*))     fgetc;
    unictx.ungetchar = (int(*)(int,void*)) ungetc;
    unictx.putchar   = (int(*)(int,void*)) fputc;
    unictx.ohandle   = stdout;

    if (!(unictx.ihandle = fopen(argv[1], "rb"))) {
        fprintf(stderr, "%s: unable to open %s\n", argv[0], argv[1]);
        return 1;
    }

    zzjson = zzjson_parse(&config);

    /* output as normal ASCII with escaped unicode characters */
    zzjson_print(&config, zzjson);

    /* output as unicode (same format as input) */
    config.ohandle = &unictx;
    config.print   = (int(*)(void*,const char*,...)) unicode_print;
    config.putchar = (int(*)(int,void*))             unicode_putchar;
//    unictx.type      = UNI_UTF32;    // set type if you want different output
//    unictx.bigendian = 1;            // and/or endianness
    zzjson_print(&config, zzjson);

    zzjson_free(&config, zzjson);
    fclose(unictx.ihandle);

    return 0;
}

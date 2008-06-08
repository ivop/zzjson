/* ZZJSON - example 1 - Copyright (C) 2008 by Ivo van Poorten
 * License: GNU Lesser General Public License version 2.1
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <sys/types.h>
#include <pwd.h>
#include "zzjson.h"

static void myerror(void *ehandle, const char *format, ...) {
    va_list ap;
    fprintf(ehandle, "error: ");
    va_start(ap, format);
    vfprintf(ehandle, format, ap);
    va_end(ap);
    fputc('\n', ehandle);
}

int main(int argc, char **argv) {
    struct passwd *pwd;
    ZZJSON_CONFIG config = { ZZJSON_VERY_STRICT, NULL, NULL, NULL,
                             malloc, calloc, free, realloc,
                             stderr, myerror, stdout,
                             (int(*)(void*,const char*,...)) fprintf,
                             (int(*)(int,void*)) fputc };
    ZZJSON *zzjson = zzjson_create_array(&config, NULL);

    while ((pwd = getpwent()) && zzjson) {
        zzjson = zzjson_array_append(&config, zzjson,
                zzjson_create_object(&config,
                    "name",   zzjson_create_string(&config, pwd->pw_name),
                    "passwd", zzjson_create_string(&config, pwd->pw_passwd),
                    "uid",    zzjson_create_number_i(&config, pwd->pw_uid),
                    "gid",    zzjson_create_number_i(&config, pwd->pw_gid),
                    "gecos",  zzjson_create_string(&config, pwd->pw_gecos),
                    "dir",    zzjson_create_string(&config, pwd->pw_dir),
                    "shell",  zzjson_create_string(&config, pwd->pw_shell),
                    NULL)
                );
    }

    if (zzjson) {
        zzjson_print(&config, zzjson);
        zzjson_free(&config, zzjson);
        return 0;
    }
    return 1;
}

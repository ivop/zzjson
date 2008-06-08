#! /bin/sh

VERSION=`grep ZZJSON_IDENT zzjson.h | cut -d '"' -f 2 | cut -d ' ' -f 2`
echo "zzjson, version $VERSION"

LIBSRC=`eval echo zzjson_{parse,print,query,create,free}.c`
CC=${CC:-cc}
LIBS="-lm -lc"
DEFINES="-D_ISOC99_SOURCE"

if test "`$CC --version 2>&1 | grep -qi gcc && echo gcc`" = gcc ; then
    echo "gnu compiler"
    echo
    WARN="-W -Wall"
    DEBUG="-g3"
    OPTMAX="-O3"
    OPTSIZ="-Os -DCONFIG_NO_ERROR_MESSAGES"
    OPTMIN="-O0"
    STRIP="-s"
elif test "`$CC -flags 2>&1 | grep -qi suncc && echo suncc`" = suncc ; then
    echo "sun compiler"
    echo
    WARN=""
    DEBUG="-g"
    OPTMAX="-xO5"
    OPTSIZ="-xO5 -xspace -DCONFIG_NO_ERROR_MESSAGES"
    OPTMIN="-xO1"
    STRIP="-s1"
else
    echo "unknown compiler... aborting" >&2
    exit 1
fi

execute() {
    echo $@
    $@
}

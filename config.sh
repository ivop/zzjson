#! /bin/sh

VERSION=`grep ZZJSON_IDENT zzjson.h | cut -d '"' -f 2 | cut -d ' ' -f 2`
echo "zzjson, version $VERSION"

LIBSRC=`eval echo zzjson_{parse,print,query,create,free}.c`
LIBBASE=libzzjson
LIBSTATICSUF=.a
LIBSHAREDSUFV=$VERSION.so
LIBSHAREDSUF=.so
EXESUF=
OBJSUF=.o

CC=${CC:-cc}
LIBS="-lm -lc"
DEFINES="-D_ISOC99_SOURCE"
AR=ar
NOLINK="-c"
SHARED="-shared"
STRIP="strip -s"

if test "`$CC --version 2>&1 | grep -qi gcc && echo gcc`" = gcc ; then
    echo "gnu compiler"
    echo
    WARN="-W -Wall"
    DEBUG="-g3"
    OPTMAX="-O3"
    OPTSIZ="-Os -DCONFIG_NO_ERROR_MESSAGES"
    OPTMIN="-O0"
elif test "`$CC -flags 2>&1 | grep -qi suncc && echo suncc`" = suncc ; then
    echo "sun compiler"
    echo
    WARN=""
    DEBUG="-g"
    OPTMAX="-xO5"
    OPTSIZ="-xO5 -xspace -DCONFIG_NO_ERROR_MESSAGES"
    OPTMIN="-xO1"
elif test "`$CC -help 2>&1 | grep -qi 'Tiny C' && echo tcc`" = tcc ; then
    echo "tiny c compiler"
    echo
    WARN="-W -Wall"
    DEBUG="-g"
    OPTMAX="-O3"
    OPTSIZ="-Os -DCONFIG_NO_ERROR_MESSAGES"
    OPTMIN="-O0"
else
    echo "unknown compiler... aborting" >&2
    exit 1
fi

execute() {
    echo $@
    $@
}

#! /bin/sh

set -e

VERSION=`grep ZZJSON_IDENT include/zzjson.h | cut -d '"' -f2 | cut -d ' ' -f2`
echo "zzjson, version $VERSION"

LIBSRC=`eval echo src/zzjson_{parse,print,query,create,free}.c`
LIBBASE=libzzjson
LIBSTATICSUF=.a
LIBSHAREDSUF=.so
LIBSHAREDSUFV=$VERSION.$LIBSHAREDSUF
EXESUF=
OBJSUF=.o

CC=${CC:-cc}
LIBS="-lm -lc"
DEFINES="-D_ISOC99_SOURCE"
AR=${AR:-ar}
NOLINK="-c"
SHARED="-shared"
STRIP="strip -s"
INCLUDES="-Iinclude"
OPTMIN="-O0"
OPTMAX="-O3"
WARN="-W -Wall"

if test "`$CC --version 2>&1 | grep -qi gcc && echo gcc`" = gcc ; then
    echo "gnu compiler"
    DEBUG="-g3"
    OPTSIZ="-Os -DCONFIG_NO_ERROR_MESSAGES"
elif test "`$CC -flags 2>&1 | grep -qi suncc && echo suncc`" = suncc ; then
    echo "sun compiler"
    WARN=""
    DEBUG="-g"
    OPTMAX="-xO5"
    OPTSIZ="-xO5 -xspace -DCONFIG_NO_ERROR_MESSAGES"
    OPTMIN="-xO1"
elif test "`$CC --version 2>&1 | grep -qi icc && echo icc`" = icc ; then
    echo "intel compiler"
    WARN="-Wall -wd810,981"
    DEBUG="-g3"
    OPTSIZ="-O2 -DCONFIG_NO_ERROR_MESSAGES"
elif test "`$CC -help 2>&1 | grep -qi 'Tiny C' && echo tcc`" = tcc ; then
    echo "tiny c compiler"
    DEBUG="-g"
    OPTSIZ="-Os -DCONFIG_NO_ERROR_MESSAGES"
else
    echo "unknown compiler... aborting" >&2
    exit 1
fi
echo

execute() {
    echo $@
    $@
}

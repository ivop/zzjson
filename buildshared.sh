#! /bin/sh

. ./config.sh

create_lib() {
    execute rm -f $LIBSO $LIBSOV
    k=""
    for i in $LIBSRC ; do
        j=${i%%.c}${OBJSUF}
        k="$k $j"
        execute $CC $NOLINK -o $j $CFLAGS $i
    done
    execute $CC $SHARED -o lib/$LIBSOV $k
    execute ln -sf $LIBSOV lib/$LIBSO
}

LIBSO=${LIBBASE}$LIBSHAREDSUF
LIBSOV=${LIBBASE}.$VERSION$LIBSHAREDSUF
CFLAGS="$INCLUDES $OPTMAX $WARN $DEFINES"
echo "*** shared library, optimized"
create_lib

LIBSO=${LIBBASE}_g$LIBSHAREDSUF
LIBSOV=${LIBBASE}_g.$VERSION$LIBSHAREDSUF
CFLAGS="$INCLUDES $OPTMIN $WARN $DEFINES $DEBUG"
echo
echo "*** shared library, non-optimized, debug info"
create_lib

LIBSO=${LIBBASE}_s$LIBSHAREDSUF
LIBSOV=${LIBBASE}_s.$VERSION$LIBSHAREDSUF
CFLAGS="$INCLUDES $OPTSIZ $WARN $DEFINES"
echo
echo "*** shared library, size optimized"
create_lib

test -n "$OBJSUF" && execute rm -f src/*${OBJSUF}

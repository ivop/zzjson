#! /bin/sh

. config.sh

create_lib() {
    execute rm -f $LIBA
    for i in $LIBSRC ; do
        j=${i%%.c}${OBJSUF}
        execute $CC $NOLINK -o $j $CFLAGS $i
        execute $AR r $LIBA $j
    done
}

LIBA=${LIBBASE}$LIBSTATICSUF
CFLAGS="$OPTMAX $WARN $DEFINES"
echo "*** static library, optimized"
create_lib

LIBA=${LIBBASE}_g$LIBSTATICSUF
CFLAGS="$OPTMIN $WARN $DEFINES $DEBUG"
echo
echo "*** static library, non-optimized, debug info"
create_lib

LIBA=${LIBBASE}_s$LIBSTATICSUF
CFLAGS="$OPTSIZ $WARN $DEFINES"
echo
echo "*** static library, size optimized"
create_lib

test -n "$OBJSUF" && execute rm -f *$OBJSUF

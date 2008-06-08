#! /bin/sh

. config.sh

create_lib() {
    execute rm -f $LIBA $LIBAV
    for i in $LIBSRC ; do
        j=${i%%.c}${OBJSUF}
        execute $CC $NOLINK -o $j $CFLAGS $i
        execute $AR r lib/$LIBAV $j
    done
    execute ln -s $LIBAV lib/$LIBA
}

LIBA=${LIBBASE}$LIBSTATICSUF
LIBAV=${LIBBASE}.$VERSION$LIBSTATICSUF
CFLAGS="$INCLUDES $OPTMAX $WARN $DEFINES"
echo "*** static library, optimized"
create_lib

LIBA=${LIBBASE}_g$LIBSTATICSUF
LIBAV=${LIBBASE}_g.$VERSION$LIBSTATICSUF
CFLAGS="$INCLUDES $OPTMIN $WARN $DEFINES $DEBUG"
echo
echo "*** static library, non-optimized, debug info"
create_lib

LIBA=${LIBBASE}_s$LIBSTATICSUF
LIBAV=${LIBBASE}_s.$VERSION$LIBSTATICSUF
CFLAGS="$INCLUDES $OPTSIZ $WARN $DEFINES"
echo
echo "*** static library, size optimized"
create_lib

test -n "$OBJSUF" && execute rm -f src/*${OBJSUF}

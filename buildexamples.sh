#! /bin/sh

. ./config.sh

COMMON="$INCLUDES $LIBS $WARN $DEFINES -D_SVID_SOURCE"

build_example() {
    echo "*** $EXEBASE, optimized, stripped"
    execute $CC -o ${EXEBASE}${EXESUF}   $SRCS $COMMON $OPTMAX
    execute $STRIP ${EXEBASE}${EXESUF}

    echo
    echo "*** $EXEBASE, non-optimized, not stripped, debug info"
    execute $CC -o ${EXEBASE}_g${EXESUF} $SRCS $COMMON $OPTMIN $DEBUG

    echo
    echo "*** $EXEBASE, size optimized, stripped"
    execute $CC -o ${EXEBASE}_s${EXESUF} $SRCS $COMMON $OPTSIZ
    execute $STRIP ${EXEBASE}_s${EXESUF}
}

EXEBASE=example1
SRCS="`eval echo examples/example1.c src/zzjson_{pr,fr,cr}*.c`"
build_example

EXEBASE=example2
COMMON="$COMMON -Iunicode"
SRCS="`eval echo examples/example2.c src/zzjson_[pf]*.c unicode/*.c`"
build_example

test -n "$OBJSUF" && execute rm -f src/*${OBJSUF}

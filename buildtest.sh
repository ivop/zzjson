#! /bin/sh

. config.sh

EXEBASE=zzjson_test

COMMON="$LIBS $WARN $DEFINES"

echo "*** test program, optimized, stripped"
execute $CC -o ${EXEBASE}${EXESUF}   zzjson_*.c $COMMON $OPTMAX $STRIP

echo
echo "*** test program, non-optimized, not stripped, debug info"
execute $CC -o ${EXEBASE}_g${EXESUF} zzjson_*.c $COMMON $OPTMIN $DEBUG

echo
echo "*** test program, size optimized, stripped"
execute $CC -o ${EXEBASE}_s${EXESUF} zzjson_*.c $COMMON $OPTSIZ $STRIP

test -n "$OBJSUF" && rm -f *${OBJSUF}

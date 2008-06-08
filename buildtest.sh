#! /bin/sh

. config.sh

EXEBASE=zzjson_test

echo "zzjson, version $VERSION"
echo

echo "*** test program, optimized, stripped"
execute $CC -o ${EXEBASE}   zzjson_*.c $LIBS $WARN $OPTMAX $STRIP $DEFINES

echo
echo "*** test program, non-optimized, not stripped, debug info"
execute $CC -o ${EXEBASE}_g zzjson_*.c $LIBS $WARN $OPTMIN $DEBUG $DEFINES

echo
echo "*** test program, size optimized, stripped"
execute $CC -o ${EXEBASE}_s zzjson_*.c $LIBS $WARN $OPTSIZ $STRIP $DEFINES

rm -f *.o

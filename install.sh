#! /bin/sh

. config.sh

PREFIX=${PREFIX:-/usr/local}
DESTDIR=${DESTDIR:-}
LIBDIR="$DESTDIR$PREFIX/lib"
INCDIR="$DESTDIR$PREFIX/include"

echo "*** installing in $DESTDIR$PREFIX"
echo

execute mkdir -p $INCDIR
execute mkdir -p $LIBDIR

execute cp -a lib/* $LIBDIR
execute cp -a include/* $INCDIR


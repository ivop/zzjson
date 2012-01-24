#! /bin/sh

. ./config.sh

echo "*** cleaning up"
echo

execute rm -f *~ */*~ \
              zzjson_test{,_g,_s}${EXESUF} \
              example1{,_g,_s}${EXESUF} \
              example2{,_g,_s}${EXESUF}
test -n "$OBJSUF"       && execute rm -f {src,unicode,examples,.}/*${OBJSUF}
test -n "$LIBSTATICSUF" && execute rm -f lib/*${LIBSTATICSUF}
test -n "$LIBSHAREDSUF" && execute rm -f lib/*${LIBSHAREDSUF}
execute rm -rf zzjson-$VERSION zzjson-$VERSION.tar.*

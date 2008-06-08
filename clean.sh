#! /bin/sh

. config.sh

echo "*** cleaning up"
echo

execute rm -f *~ \
              zzjson_test${EXESUF} \
              zzjson_test_g${EXESUF} \
              zzjson_test_s${EXESUF} \
              example1${EXESUF} example2${EXESUF}
test -n "$OBJSUF"       && execute rm -f src/*${OBJSUF}
test -n "$LIBSTATICSUF" && execute rm -f lib/*${LIBSTATICSUF}
test -n "$LIBSHAREDSUF" && execute rm -f lib/*${LIBSHAREDSUF}

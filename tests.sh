#! /bin/sh

for i in test/*.json; do
    ./zzjson_test $i >/dev/null 2>&1 && echo "OK $i" || echo "FAIL $i"
done | sort

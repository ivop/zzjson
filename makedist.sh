#! /bin/sh

. ./config.sh


BASEURL=https://zzjson.svn.sourceforge.net/svnroot/zzjson/

test -z "$1" && echo "specify 'trunk' or a specific branch or tag" && exit 2

echo "*** retrieving $BASEURL$1"
svn export -q $BASEURL/$1 zzjson-$VERSION

execute rm -f zzjson-$VERSION/makedist.sh
execute chown -R nobody:nogroup zzjson-$VERSION

execute tar cjf zzjson-$VERSION.tar.bz2 zzjson-$VERSION
execute tar czf zzjson-$VERSION.tar.gz zzjson-$VERSION

execute rm -rf zzjson-$VERSION

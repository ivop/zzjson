#! /bin/sh

# iconv does not always output a BOM, so we work around that

for i in "utf-8,\xef\xbb\xbf" \
         "utf-16le,\xff\xfe" \
         "utf-16be,\xfe\xff" \
         "utf-32le,\xff\xfe\x00\x00" \
         "utf-32be,\x00\x00\xfe\xff" ; do
    j=`echo $i | cut -d ',' -f 1`
    bom=`echo $i | cut -d ',' -f 2`
    /usr/bin/printf "$bom" > $j.json
    iconv -f ISO-8859-1 -t $j ISO-8859-1.json >> $j.json
done

iconv -f ISO-8859-1 -t utf-8 ISO-8859-1.json > utf-8-wo-bom.json


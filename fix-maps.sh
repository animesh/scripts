#!/bin/sh

rm -f t.sed
touch t.sed
for f in seq*name
do b=`basename $f name`
   #n=$(cat $f | pip-quote-ps-string)
   n=` cat $f | tr -d '\r\n' | tr -c 'a-zA-Z0-9 ' '_' `
   test -n "${n}" && echo "s/${b}data/${n}/" >>t.sed
done
sed -f t.sed

#!/bin/sh
# XXX - hardcoded paths

: ${TXT_MAX:=1000000}

if grep '^a[ \t]*{' out.blastz >/dev/null;
then lat 1- out.blastz;
else echo 'Empty alignment.';
fi >out.lat 2>out.lat.err

case $? in
0) if [ "`wc -c < out.lat`" -gt "$TXT_MAX" ]; then
   echo "pipmaker: verbose text is bigger than $TXT_MAX bytes; discarding it." >out.lat
   fi
   ;;
*) echo "pipmaker: lat failed; its incomplete output has been deleted." >out.lat
   cat out.lat.err >>out.lat
   ;;
esac


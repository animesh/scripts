#!/bin/bash
#
for SONG in *.mp3
do

echo "playing => $SONG"
cp ./"$SONG" /tmp/play.mp3.$$
mpg123 /tmp/play.mp3.$$ 2>/dev/null
rm -f /tmp/play.mp3.$$

done
#
exit 0

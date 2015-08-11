#!/bin/sh
JDK=/usr/local/java/bin
PATH=$JDK:$PATH
export PATH

CLASSPATH=/usr/local/align/lib/laj/lat.jar
export CLASSPATH

exec java -Xmx200000000 edu.psu.cse.bio.laj.LatMain "$@"


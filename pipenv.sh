#!/bin/sh

prefix=/usr/local/align

PH=$prefix/pipmaker
PU=pipserv
PG=pipserv
URL=http://bio.cse.psu.edu/pipmaker/
HU=httpd

exec env - \
HTTPUSER=$HU \
PIPUSER=$PU \
PIPGROUP=$PG \
PIPHOME=$PH \
PIPURL=$URL \
	    \
BLASTDB=$PH/lib \
HOME=$PH \
USER=$PU \
LOGNAME=$PU \
	    \
PATH=\
$PH/bin:\
$prefix/bin:\
/usr/local/bin:\
/usr/bin:\
/bin \
     \
"$@"

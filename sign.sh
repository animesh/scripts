#!/bin/bash
echo "Peter Kirby <kirby@earthlink.net>"

STR=$(uptime)
TIME=${STR% user*}
RESULT=${TIME% *}
echo -n $RESULT
echo " Mandrake Linux 9.0, kernel $(uname -r) on AMD Athlon 750"


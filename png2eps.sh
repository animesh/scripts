#!/bin/sh
#pngtopnm $1 | pnmtops -noturn -nocenter -scale 0.20 - >$2
pngtopnm $1 | pnmtops -noturn -nocenter -scale 1.00 - >$2

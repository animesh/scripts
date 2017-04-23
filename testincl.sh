#!/bin/sh
## test of EPS inclusion in METAPOST file
mpost testincl.mp
gawk -f epsincl.awk testincl.100 > testincl.eps

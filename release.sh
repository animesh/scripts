#!/bin/bash
SLIST="site/COPYING README release.sh Makefile* configure* config.h config.h.in src/Makefile* src/*.cc src/*.cxx src/*.fl src/*.h"
BLIST="omw"
FBASE="fr.inx fr.dat"
EBASE="eng.inx eng.dat"


cp -f /mnt/win98/linux/pcm/omw/src/omw.exe .
cp -f /mnt/win98/linux/pcm/omw/src/Makefile src/Makefile.src.mingwin32

zip omw.exe.zip omw.exe
mv -f omw.exe.zip site

zip site/omwsrc.zip $SLIST


make clean
make
cp -f src/omw omw
zip site/omwbin.zip $BLIST
zip site/omwbasefr.zip $FBASE
zip site/omwbaseen.zip $EBASE


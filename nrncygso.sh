#!/bin/sh

set -x

#all the .o files
find .. -name \*.o -print | sed '
/\/modlunit\//d
/\/nmodl\//d
/\/e_editor\//d
/\/ivoc\/classreg\.o/d
/\/ivoc\/datapath\.o/d
/\/ivoc\/nrnmain\.o/d
/\/ivoc\/ocjump\.o/d
/\/ivoc\/symdir\.o/d
/\/ivoc\/\.libs\/ivocman1\.o/d
/\/nrnoc\/cprop\.o/d
/\/oc\/\.libs\/code\.o/d
/\/oc\/\.libs\/hoc_init\.o/d
/\/oc\/\.libs\/hoc_oop\.o/d
/\/oc\/\.libs\/hocusr\.o/d
/\/oc\/\.libs\/plt\.o/d
/\/oc\/\.libs\/settext\.o/d
/\/oc\/\.libs\/spinit\.o/d
/\/oc\/\.libs\/spinit1\.o/d
/\/oc\/\.libs\/spinit2\.o/d
/\/memacs\/\.libs\/termio\.o/d
/\/memacs\/main\.o/d
/\/nvkludge\.o/d
/\/nocable\.o/d
/\/nrnnoiv\.o/d
/\/ockludge\.o/d
/\/ocnoiv\.o/d
/\/ocmain\.o/d
/\/inithoc\.o/d
' > temp

mpicc=

if test "$mpicc" = "mpicc" ; then
mpich=`which $mpicc | sed "s,/bin/.*,,"`
echo "mpich=$mpich"
# mpich configured and made with
#./configure '--prefix=/home/Hines/mpich2' '--with-device=ch3:nemesis' \
#  'pac_cv_f77_sizeof_integer=4' 'pac_cv_f77_sizeof_double_precision=8' \
#  'CFLAGS=-DDLL_EXPORT -DPIC' 'CXXFLAGS=-DDLL_EXPORT -DPIC'
#make >& build.stdout
# did not do a make install

awk '
/Entering directory/ { d = $4 }
/ar cr/ { for (i=4; i <= NF; ++i) {
	printf("%s/%s\n", d, $i)
}}
' $mpich/build.stdout | sed "s/'//
	s/\`//
	/\.no$/d
	/\.po$/d
	/\/hydra\/d
	/\/c++\//d
	/\/mpe2\//d
	/\/binding\/f77\//d
	"'$a \
'$mpich/src/binding/f77/setbot.o'
' >> temp

fi

#nrnpy='yes'
nrnpy='no'
#nrnjvm='yes'
nrnjvm='no'

#sed 's,^.*/,,' temp |sort|uniq -d
obj=`cat temp`

CXX=g++

echo IVLIBDIR=\"${IVLIBDIR}\"
echo CFLAGS=\"${CFLAGS}\"
echo LDFLAGS=\"${LDFLAGS}\"

if test "$CFLAGS" != "-mno-cygwin" ; then

echo 'make nrniv.dll'
$CXX -shared $obj \
  -L${IVLIBDIR} -lIVhines \
  -lcygwin -luser32 -lkernel32 -ladvapi32 -lshell32 \
  $LIBS \
   \
  -lgdi32 -lcomdlg32 -lncurses -lm \
  -o nrniv.dll \
  -Wl,--enable-auto-image-base \
  ${LDFLAGS} \
  -Xlinker --out-implib -Xlinker libnrniv.dll.a

if test $nrnpy = 'yes' ; then
echo 'make hocmodule.dll'
$CXX -shared \
  ../nrnpython/.libs/inithoc.o \
  -L. -lnrniv \
   \
  -o hocmodule.dll \
  -Wl,--enable-auto-image-base \
  ${LDFLAGS} \
  -Xlinker --out-implib -Xlinker libhocmodule.dll.a

LHOCMODULE='-lhocmodule'
else
LHOCMODULE=''
fi

echo 'make nrniv.exe'
$CXX -g -O2 -mwindows -e _mainCRTStartup -o nrniv.exe \
  ../ivoc/nrnmain.o ../oc/modlreg.o \
  -L. -lnrniv \
  $LHOCMODULE \
  -lncurses \
  -L${IVLIBDIR} -lIVhines \
  -lstdc++ -lgdi32 -lcomdlg32 \
  ${LDFLAGS} \
  

else

$CXX -shared -mno-cygwin $obj \
  $LIBS -lstdc++ \
   \
  -o nrniv.dll \
  -Wl,--enable-auto-image-base \
  ${LDFLAGS} \
  -Xlinker --out-implib -Xlinker libnrniv.dll.a

$CXX -shared -mno-cygwin \
  ../nrnpython/.libs/inithoc.o \
   \
  -L. -lnrniv -lstdc++ \
  -o hocmodule.dll \
  -Wl,--enable-auto-image-base \
  ${LDFLAGS} \
  -Xlinker --out-implib -Xlinker libhocmodule.dll.a

$CXX -g -O2 -mno-cygwin -e _mainCRTStartup -o nrniv.exe \
  ../ivoc/nrnmain.o ../oc/modlreg.o \
  -L. -lnrniv -lstdc++ \
  ${LDFLAGS} \
  

fi

#mv nrniv.exe c:/nrn61/bin
#cd ..
#mv hocmodule.dll c:/nrn61/bin


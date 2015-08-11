#!/bin/sh

./make-enc.pl T2Auni.map T2AAdobe glyphlist.txt > encfiles/t2a.enc
./make-enc.pl T2Buni.map T2BAdobe glyphlist.txt > encfiles/t2b.enc
./make-enc.pl T2Cuni.map T2CAdobe glyphlist.txt > encfiles/t2c.enc
./make-enc.pl X2uni.map X2Adobe glyphlist.txt > encfiles/x2.enc

./make-enc.pl T2Auni.map T2AModified1 glyphlist.txt broken1.txt | sed 's,/afii.*,/.notdef,' > encfiles/t2a-mod1.enc
#./make-enc.pl T2Buni.map T2BModified1 glyphlist.txt broken1.txt | sed 's,/afii.*,/.notdef,' > encfiles/t2b-mod1.enc
#./make-enc.pl T2Cuni.map T2CModified1 glyphlist.txt broken1.txt | sed 's,/afii.*,/.notdef,' > encfiles/t2c-mod1.enc
#./make-enc.pl X2uni.map X2Modified1 glyphlist.txt broken1.txt | sed 's,/afii.*,/.notdef,' > encfiles/x2-mod1.enc

./make-enc.pl T2Auni.map T2AModified2 glyphlist.txt broken2.txt | sed 's,/afii.*,/.notdef,' > encfiles/t2a-mod2.enc
#./make-enc.pl T2Buni.map T2BModified2 glyphlist.txt broken2.txt | sed 's,/afii.*,/.notdef,' > encfiles/t2b-mod2.enc
#./make-enc.pl T2Cuni.map T2CModified2 glyphlist.txt broken2.txt | sed 's,/afii.*,/.notdef,' > encfiles/t2c-mod2.enc
#./make-enc.pl X2uni.map X2Modified2 glyphlist.txt broken2.txt | sed 's,/afii.*,/.notdef,' > encfiles/x2-mod2.enc

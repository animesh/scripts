#! /bin/bash
sed -n '/ def /p' macro/la3Dmacros.mp > la3Ddef.txt
sed -n '/ vardef /p' macro/hlr3Dmacros.mp > hlr3Dvardef.txt
sed -n '/ def /p' macro/hlr3Dmacros.mp > hlr3Ddef.txt
cat la3Ddef.txt hlr3Dvardef.txt hlr3Ddef.txt > alldef.txt
rm -v la3Ddef.txt hlr3Dvardef.txt hlr3Ddef.txt 
# there are two "vardefined" procedures:
# makeline@# and makeface@# 

#!/bin/sh


############################################################################
#
# Generic Sanger clipping call with MIRA
#
############################################################################

echo "Loading and clipping normal Sanger data. In this case, good clippings"
echo "are already present in the XML file, but this shows you how to "
echo "combine loading of XML TRACEINFO data with own clippings."
echo "You might want to put in your own preprocessing data into the XML."
echo
time miraclip -project=$1 -fasta=$1_in.sanger.fasta -GE:mxti=yes -FN:xtii=$1_traceinfo_in.sanger.xml:cafout=$1_clipped.sanger.caf -CL:qc=yes:bsqc=yes:mbc=yes:emlc=yes >&log_sangerpre.txt

if [ $? -gt 0 ]; then
  echo
  echo "MIRAclip did not run correctly. Please consult log_sangerpre.txt"
  exit
fi


############################################################################
#
# Generic 454 loading call with MIRA
#
############################################################################

echo 
echo "Loading and clipping 454 data."
echo "This will basically load the 454 data, attach some meta-information and"
echo "write back to a CAF file. As all clipping options are switched off (the"
echo "-CL options), no clipping will be performed."

time miraclip  -project=$1 -FN:xtii=$1_traceinfo_in.454.xml:cafout=$1_clipped.454.caf  -GE:mxti=yes  -454data -454:l454d=yes  -CL:msvs=no:qc=no:bsqc=no:pvlc=no:mbc=no:emlc=no  -DP:ure=no >&log_454pre.txt 

if [ $? -gt 0 ]; then
  echo
  echo "MIRAclip did not run correctly. Please consult log_454pre.txt."
  exit
fi

############################################################################
#
# Combining clipped Sanger & 454 data
#
############################################################################

echo "Concatenating Sanger and 454 clipping result files."
echo
cat $1_clipped.454.caf $1_clipped.sanger.caf >$1_in.caf

# cleaning up a bit
rm $1_clipped.454.caf $1_clipped.sanger.caf
rm log_*pre.txt
#
echo 
echo "The Sanger and 454 data is now ready to be assembled."
echo


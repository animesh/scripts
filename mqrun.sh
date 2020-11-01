#USAGE: bash mqrun.sh
#make sure mqrun.xml is in the directory where the script is and CHANGE following paths according to the MaxQuant Installation, directory containing experiment raw files, fasta file and representative parameter file for that version respectively
MAXQUANTCMD=$HOME/MaxQuant_1.6.8.0/MaxQuant/bin/MaxQuantCmd.exe
CPU=16
DATADIR=$HOME/HF/BSA/
FASTAFILE=$HOME/FastaDB/crap.fasta
PARAMFILE=mqpar.xml
#leave following empty to include ALL files
PREFIXRAW=
SEARCHTEXT=TestFile.raw
SEARCHTEXT2=SequencesFasta
SEARCHTEXT3=LocalCombinedFolder
LDIR=$PWD
CURRENTEPOCTIME=`date +%s`
WRITEDIR=$PARAMFILE.$CURRENTEPOCTIME.results
mkdir $WRITEDIR
for i in $DATADIR/*.raw ; do echo $i ; 	j=$(basename $i) ; 	k=${j%%.*} ; mkdir $WRITEDIR/$k ; cp $i $WRITEDIR/$k ; sed "s|$SEARCHTEXT2|$FASTAFILE|" $LDIR/$PARAMFILE > $WRITEDIR/$k/$PARAMFILE.tmp1 ; 	sed "s|$SEARCHTEXT|$LDIR/$WRITEDIR/$k/$j|"  $WRITEDIR/$k/$PARAMFILE.tmp1 > $WRITEDIR/$k/$PARAMFILE.tmp2 ; sed "s|$SEARCHTEXT3|$LDIR/$WRITEDIR/$k|"  $WRITEDIR/$k/$PARAMFILE.tmp2 > $WRITEDIR/$k/$k.xml ; rm $WRITEDIR/$k/$PARAMFILE.tmp*  ;done
#mono $MAXQUANTCMD $k.xml ; cp -rf ./combined/txt $k.REP ; echo $k ; cd $LDIR 
find $WRITEDIR -name "*.xml" | parallel -j $CPU "mono $MAXQUANTCMD {}"
#perl -pe 's/\r$//' < mqrun.sh  > tmp
#mv tmp  mqrun.sh
#mono $HOME/data/NORSTORE_OSL_DISK/NS9036K/promec/MaxQuant_1.6.8.0/MaxQuant/bin/MaxQuantCmd.exe -n $HOME/promec/Qexactive/Mirta/QExactive/Imen_Belhaj/RawData/out1678.xml
#-n for dryrun, -p <#checkpoint>

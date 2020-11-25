/bin/bash
#change the following paths according to the AriocP Installation, directory containing experiment fasta/q files, ref fasta file and representative configuration file './AriocP.cfg' for that version respectively
cd
wget https://github.com/RWilton/Arioc/releases/download/v1.42/Arioc.x.142.zip
unzip Arioc.x.142.zip 
make AriocP release
$HOME/bin/AriocP
AriocPCMD=$HOME/AriocP.x.142/AriocP/bin/AriocPCmd.exe
CPU=16
DATADIR=$HOME/Animesh/Pseudomonas/
FASTAFILE=$HOME/Animesh/Pseudomonas/Pse.fasta.uniq.fasta
PARAMFILE=mqpar.xml
#leave following empty to include ALL files
PREFIXRAW=
SEARCHTEXT=TestFile.fastq
SEARCHTEXT2=SequencesFasta
SEARCHTEXT3=LocalCombinedFolder
LDIR=$PWD
CURRENTEPOCTIME=`date +%s`
WRITEDIR=$PARAMFILE.$CURRENTEPOCTIME.results
mkdir $WRITEDIR
for i in $DATADIR/*raw ; do echo $i ; 	j=$(basename $i) ; 	k=${j%%.*} ; mkdir $WRITEDIR/$k ; cp $i $WRITEDIR/$k ; sed "s|$SEARCHTEXT2|$FASTAFILE|" $LDIR/$PARAMFILE > $WRITEDIR/$k/$PARAMFILE.tmp1 ; 	sed "s|$SEARCHTEXT|$LDIR/$WRITEDIR/$k/$j|"  $WRITEDIR/$k/$PARAMFILE.tmp1 > $WRITEDIR/$k/$PARAMFILE.tmp2 ; sed "s|$SEARCHTEXT3|$LDIR/$WRITEDIR/$k|"  $WRITEDIR/$k/$PARAMFILE.tmp2 > $WRITEDIR/$k/$k.xml ; rm $WRITEDIR/$k/$PARAMFILE.tmp*  ;done
#mono $AriocPCMD $k.xml ; cp -rf ./combined/txt $k.REP ; echo $k ; cd $LDIR 
find $WRITEDIR -name "*.xml" | parallel -j $CPU "mono $AriocPCMD {}"
#perl -pe 's/\r$//' < mqrun.sh  > tmp
#mv tmp  mqrun.sh
#mono $HOME/data/NORSTORE_OSL_DISK/NS9036K/promec/AriocP.x.142/AriocP/bin/AriocPCmd.exe -n $HOME/promec/Qexactive/Mirta/QExactive/Imen_Belhaj/RawData/out1678.xml
#-n for dryrun, -p <#checkpoint>
#date -d @1604251727

#bash mqrunTTP.sh $HOME/MaxQuant_v.2.0.2.0/bin/MaxQuantCmd.exe $HOME/promec/_Training-tims-TOF-Pro $HOME/FastaDB/uniprot-human-iso-june21.fasta mqparTTP.xml 8
#USAGE: bash mqrun.sh <full path to MaxQuantCmd.exe> <full path to directory containing raw.d folders/> <full path to the fasta file> <mqpar file in working directory> <number of cpu to use>
#make sure mqrun.xml is in the directory where the script is and CHANGE following paths according to the MaxQuant Installation and representative parameter file for that version respectively
#CANNOT handle path containing spaces! create a symlink in such cases e.g. 
#ln -s /home/ash022/PD/USERS/STAMI/2021-02-23\ 6\ test\ samples /home/ash022/PD/USERS/STAMI/2021-02-23-6testsamples
MAXQUANTCMD=$1
DATADIR=$2
FASTAFILE=$3
PARAMFILE=$4
CPU=$5
#leave following empty to include ALL files
PREFIXRAW=
SEARCHTEXT=TestFile.d
SEARCHTEXT2=SequencesFasta
SEARCHTEXT3=LocalCombinedFolder
LDIR=$PWD
CURRENTEPOCTIME=`date +%s`
WRITEDIR=$PARAMFILE.$CURRENTEPOCTIME.results
mkdir $WRITEDIR
for i in $DATADIR/*.d ; do echo $i ; 	j=$(basename $i) ; 	k=${j%%.*} ; mkdir $WRITEDIR/$k ; cp -r $i $WRITEDIR/$k ; sed "s|$SEARCHTEXT2|$FASTAFILE|" $LDIR/$PARAMFILE > $WRITEDIR/$k/$PARAMFILE.tmp1 ; 	sed "s|$SEARCHTEXT|$LDIR/$WRITEDIR/$k/$j|"  $WRITEDIR/$k/$PARAMFILE.tmp1 > $WRITEDIR/$k/$PARAMFILE.tmp2 ; sed "s|$SEARCHTEXT3|$LDIR/$WRITEDIR/$k|"  $WRITEDIR/$k/$PARAMFILE.tmp2 > $WRITEDIR/$k/$k.xml ; rm $WRITEDIR/$k/$PARAMFILE.tmp*  ;done
#mono $MAXQUANTCMD $k.xml ; cp -rf ./combined/txt $k.REP ; echo $k ; cd $LDIR 
ls -1 $WRITEDIR/*/*.xml | parallel -j $CPU "mono $MAXQUANTCMD {}"
#perl -pe 's/\r$//' < mqrun.sh  > tmp
#mv tmp  mqrun.sh
#mono $HOME/data/NORSTORE_OSL_DISK/NS9036K/promec/MaxQuant_1.6.8.0/MaxQuant/bin/MaxQuantCmd.exe -n $HOME/promec/Qexactive/Mirta/QExactive/Imen_Belhaj/RawData/out1678.xml
#-n for dryrun, -p <#checkpoint>
#date -d @1604251727
echo $WRITEDIR
#find $WRITEDIR -name "proteinGroups.txt"  | xargs ls -ltrh
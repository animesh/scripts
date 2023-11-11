#$HOME/bin/fragpipe --headless --threads 20 --ram 80 --workflow fp.workflow.txt --manifest fp.manifest.txt --workdir fptest
#bash fprunTTP.sh $HOME/bin/fragpipe $HOME/PD/TIMSTOF/LARS/2022/RTstandards/ 
#CANNOT handle path containing spaces! create a symlink in such cases e.g. 
#for i in $HOME/PD/TIMSTOF/LARS/2021/November/*.d ; do echo $i; j=${i// /_}; echo $j; k=$(basename $j) ; echo $k; ln -s "$i" "$k"; done
FPQUANTCMD=$1
DATADIR=$2
FASTAFILE=$3
PARAMFILE=$4
CPU=$5
FDR=$6
#leave following empty to include ALL files
PREFIXRAW=
SEARCHTEXT=TestFile.d
SEARCHTEXT2=SequencesFasta
SEARCHTEXT3=LocalCombinedFolder
SEARCHTEXT4="Fdr>0.01"
LDIR=$PWD
CURRENTEPOCTIME=`date +%s`
WRITEDIR=$PARAMFILE.$CURRENTEPOCTIME.results
mkdir $WRITEDIR
for i in $DATADIR/*.d ; do echo $i ; 	j=$(basename $i) ; 	k=${j%%.*} ; mkdir $WRITEDIR/$k ; cp -r $i $WRITEDIR/$k ; sed "s|$SEARCHTEXT2|$FASTAFILE|" $LDIR/$PARAMFILE > $WRITEDIR/$k/$PARAMFILE.tmp1 ; sed "s|$SEARCHTEXT|$LDIR/$WRITEDIR/$k/$j|"  $WRITEDIR/$k/$PARAMFILE.tmp1 > $WRITEDIR/$k/$PARAMFILE.tmp2 ; sed "s|$SEARCHTEXT4|Fdr>$FDR|"  $WRITEDIR/$k/$PARAMFILE.tmp2 > $WRITEDIR/$k/$PARAMFILE.tmp3 ; sed "s|$SEARCHTEXT3|$LDIR/$WRITEDIR/$k|"  $WRITEDIR/$k/$PARAMFILE.tmp3 > $WRITEDIR/$k/$k.xml ; rm $WRITEDIR/$k/$PARAMFILE.tmp*  ;done
#mono $FPQUANTCMD $k.xml ; cp -rf ./combined/txt $k.REP ; echo $k ; cd $LDIR 
ls -1 $WRITEDIR/*/*.xml | parallel -j $CPU "mono $FPQUANTCMD {}"
#perl -pe 's/\r$//' < mqrun.sh  > tmp
#mv tmp  mqrun.sh
#mono $HOME/data/NORSTORE_OSL_DISK/NS9036K/promec/FPQuant_1.6.8.0/FPQuant/bin/FPQuantCmd.exe -n $HOME/promec/Qexactive/Mirta/QExactive/Imen_Belhaj/RawData/out1678.xml
#-n for dryrun, -p <#checkpoint>
#date -d @1604251727
echo $WRITEDIR
#find $WRITEDIR -name "proteinGroups.txt"  | xargs ls -ltrh
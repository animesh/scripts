#USAGE: bash mqrunTTPdia.sh $HOME/MaxQuant_2.0.3.0/bin/MaxQuantCmd.exe $HOME/PD/TIMSTOF/LARS/2021/Oktober/211013_Shengdong/DIA/DIA/DIA $PWD/human.fasta $HOME/PROMEC/promec/libMQ/homo_sapiens/missed_cleavages_1/peptides/peptides.txt $HOME/PROMEC/promec/libMQ/homo_sapiens/missed_cleavages_1/evidence/evidence.txt $HOME/PROMEC/promec/libMQ/homo_sapiens/missed_cleavages_1/msms/msms.txt mqparTTPdia.xml 16
#CANNOT handle path containing spaces! create a symlink in such cases e.g. 
#for i in $HOME/PD/TIMSTOF/LARS/2021/SEPTEMBER/*Finn*/try*/*.d; do echo $i; j=${i// /_}; echo $j; k=$(basename $j) ; echo $k; ln -s "$i" "$k"; done
MAXQUANTCMD=$1
DATADIR=$2
FASTAFILE=$3
PEPFILE=$4
EVIFILE=$5
MSMSFILE=$6
PARAMFILE=$7
CPU=$8
#leave following empty to include ALL files
PREFIXRAW=
SEARCHTEXT=TestFile.d
SEARCHTEXT2=SequencesFasta
SEARCHTEXT3=PeptidesFile
SEARCHTEXT4=EvidenceFile
SEARCHTEXT5=msmsFile
SEARCHTEXT6=LocalCombinedFolder
LDIR=$PWD
CURRENTEPOCTIME=`date +%s`
WRITEDIR=$PARAMFILE.$CURRENTEPOCTIME.results
mkdir $WRITEDIR
for i in $DATADIR/*.d ; do echo $i ; 	j=$(basename $i) ; 	k=${j%%.*} ; mkdir $WRITEDIR/$k ; cp -r $i $WRITEDIR/$k ; sed "s|$SEARCHTEXT2|$FASTAFILE|" $LDIR/$PARAMFILE > $WRITEDIR/$k/$PARAMFILE.tmp1 ; 	sed "s|$SEARCHTEXT|$LDIR/$WRITEDIR/$k/$j|"  $WRITEDIR/$k/$PARAMFILE.tmp1 > $WRITEDIR/$k/$PARAMFILE.tmp2 ; sed "s|$SEARCHTEXT6|$LDIR/$WRITEDIR/$k|"  $WRITEDIR/$k/$PARAMFILE.tmp2 > $WRITEDIR/$k/$PARAMFILE.tmp3  ; sed "s|$SEARCHTEXT3|$PEPFILE|"  $WRITEDIR/$k/$PARAMFILE.tmp3 > $WRITEDIR/$k/$PARAMFILE.tmp4  ; sed "s|$SEARCHTEXT4|$EVIFILE|"  $WRITEDIR/$k/$PARAMFILE.tmp4 > $WRITEDIR/$k/$PARAMFILE.tmp5 ; sed "s|$SEARCHTEXT5|$MSMSFILE|"  $WRITEDIR/$k/$PARAMFILE.tmp5 >  $WRITEDIR/$k/$k.xml ; rm $WRITEDIR/$k/$PARAMFILE.tmp*  ;done
#mono $MAXQUANTCMD $k.xml ; cp -rf ./combined/txt $k.REP ; echo $k ; cd $LDIR 
ls -1 $WRITEDIR/*/*.xml | parallel -j $CPU "mono $MAXQUANTCMD {}"
#perl -pe 's/\r$//' < mqrun.sh  > tmp
#mv tmp  mqrun.sh
#mono $HOME/data/NORSTORE_OSL_DISK/NS9036K/promec/MaxQuant_1.6.8.0/MaxQuant/bin/MaxQuantCmd.exe -n $HOME/promec/Qexactive/Mirta/QExactive/Imen_Belhaj/RawData/out1678.xml
#-n for dryrun, -p <#checkpoint>
#date -d @1604251727
echo $WRITEDIR
#ls -ltrh mqparTTP.xml.*.results
#watch ls -ltrh mqparTTP.xml.*.results/211102*/combined/proc
#find $WRITEDIR -name "proteinGroups.txt"  | xargs ls -ltrh

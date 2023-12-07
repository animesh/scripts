#git checkout 7cca5a459b903717c5dbf7f08cfb51ef31345a3b scratch.slurm slurmMQrunTTP.sh mqparTTPdia.xml
#dos2unix scratch.slurm slurmMQrunTTP.sh mqparTTPdia.xml
#bash slurmMQrunTTP.sh /cluster/projects/nn9036k/MaxQuant_v_2.4.10.0/bin/MaxQuantCmd.exe /cluster/projects/nn9036k/scripts/231128_plasma_KF/DIA /cluster/projects/nn9036k/FastaDB mqparTTPdia.xml scratch.slurm
#rsync -Parv login.nird-lmd.sigma2.no:/nird/projects/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2023/230504_hela_test/DIA/ helaDIA/
#wget "https://maxquant.org/p/maxquant/MaxQuant_v_2.4.10.0.zip?md5=bwPYOvsI5oXolBP_wXUyzg&expires=1700127616" -O MQv24100.zip
#unzip MQv24100.zip
#wget "https://datashare.biochem.mpg.de/s/qe1IqcKbz2j2Ruf/download?path=%2FDiscoveryLibraries&files=homo_sapiens.zip" -O HS.DIA.zip
#unzip HS.DIA.zip
#mv *.fasta FastaDB/.
#mv *.txt FastaDB/.
#mv MaxQuant_v_1.4.10.0 MaxQuant_v_2.4.10.0
MAXQUANTCMD=$1
DATADIR=$2
FASTADIR=$3
PARAMFILE=$4
MQSLURMFILE=$5
CPU=10
thrMS=20
#leave following empty to include ALL files
PREFIXRAW=
SEARCHTEXT=TestFile.d
SEARCHTEXT2=SequencesFasta
SEARCHTEXT3=LocalCombinedFolder
SEARCHTEXT4=thrMS
LDIR=$PWD
CURRENTEPOCTIME=`date +%s`
WRITEDIR=$PARAMFILE.$CURRENTEPOCTIME.results
mkdir $WRITEDIR
#perl -pe 's/\r$//' < mqrun.sh  > tmp
dos2unix $PARAMFILE $MQSLURMFILE
for i in $DATADIR/*.d ; do echo $i ; 	j=$(basename $i) ; 	k=${j%%.*} ; mkdir $WRITEDIR/$k ; cp -Lr $i $WRITEDIR/$k ; sed "s|$SEARCHTEXT2|$FASTADIR|g" $LDIR/$PARAMFILE > $WRITEDIR/$k/$PARAMFILE.tmp1 ; sed "s|$SEARCHTEXT|$LDIR/$WRITEDIR/$k/$j|"  $WRITEDIR/$k/$PARAMFILE.tmp1 > $WRITEDIR/$k/$PARAMFILE.tmp2 ; sed "s|$SEARCHTEXT4|$thrMS|g"  $WRITEDIR/$k/$PARAMFILE.tmp2 > $WRITEDIR/$k/$PARAMFILE.tmp3 ; sed "s|$SEARCHTEXT3|$LDIR/$WRITEDIR/$k|"  $WRITEDIR/$k/$PARAMFILE.tmp3 > $WRITEDIR/$k/$k.xml ; rm $WRITEDIR/$k/$PARAMFILE.tmp*  ;done
#mono $MAXQUANTCMD $k.xml ; cp -rf ./combined/txt $k.REP ; echo $k ; cd $LDIR 
echo $WRITEDIR
#mv tmp  mqrun.sh
#mono $HOME/data/NORSTORE_OSL_DISK/NS9036K/promec/MaxQuant_1.6.8.0/MaxQuant/bin/MaxQuantCmd.exe -n $HOME/promec/Qexactive/Mirta/QExactive/Imen_Belhaj/RawData/out1678.xml
#-n for dryrun, -p <#checkpoint>
#date -d @1604251727
#find $WRITEDIR -name "proteinGroups.txt"  | xargs ls -ltrh
for i in $PWD/$WRITEDIR/*/*.xml
#dos2unix scratch.slurm 
#for i in $PWD/mqparTTP.phoSTY.xml.1663657305.results/*/*.xml 
    do echo $i
    j=$(basename $i)
    k=${j%%.*}
    d=$(dirname $i) 
    printf "$i\t$j\t$kt\t$d\n" | tee $d/$k.txt
    cat $d/$k.txt
    #cp MQSLURMFILE $d/$k.slurm 
    cp scratch.slurm $d/$k.slurm 
    sed "s|MQSLURMNAME|$k|" $d/$k.slurm  > slurm.tmp
    sed "s|MQSLURMLOG|$d/$k.txt|" slurm.tmp > slurm.tmp2
    sed "s|MQCMD|$MAXQUANTCMD|" slurm.tmp2 > slurm.tmp
    sed "s|MQWD|$d|" slurm.tmp > slurm.tmp2
    sed "s|MQPARF|$i|" slurm.tmp2 > $d/$k.slurm
    cat $d/$k.slurm
    sbatch $d/$k.slurm
done
tail -n 4 $WRITEDIR/*/*.slurm
ls $WRITEDIR/*/*.slurm | wc
#for i in mqparTTPdia.xml.1699532779.results/*/*.slurm ; do echo $i ; sed -i 's|1G|4G|g' $i ; sbatch $i; done

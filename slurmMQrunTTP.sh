#git checkout 1b88b4332b7afe044820ee5eff575b13006fa04c mqparTTPdda.xml mqparTTPdia.xml scratch.slurm slurmMQrunTTP.sh
#dos2unix mqparTTPdda.xml scratch.slurm slurmMQrunTTP.sh
#cp  $HOME/PD/TIMSTOF/LARS/2025/25*Mit*/*opy*xml .
#mv *Copy*xml mqpar.mitra.xml
#cp  $HOME/PD/TIMSTOF/LARS/2024/240819_Mitra/*.fas* $HOME/cluster/FastaDB/
#[ash022@login-3.SAGA ~/scripts]$ vim slurmMQrunTTP.sh :%s/F:\\promec\\TIMSTOF\\LARS\\2024\\240819_Mitra\\/\/cluster\/projects\/nn9036k\/FastaDB\//g
#bash slurmMQrunTTP.sh /cluster/projects/nn9036k/MaxQuant_v2.6.5.0/bin/MaxQuantCmd.dll /nird/datapeak/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2025/250225_Mitra /cluster/projects/nn9036k/FastaDB/IDH1mutHUMAN.fasta mqpar.mitra.xml scratch.slurm 
#cp mqpar.mitra.xml mqparTTPdda.xml
#tail -f mqpar.mitra.xml.1741954645.results/*/*.txt
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
dos2unix $PARAMFILE
for i in $DATADIR/*.d ; do echo $i ; 	j=$(basename $i) ; 	k=${j%%.*} ; mkdir $WRITEDIR/$k ; cp -r $i $WRITEDIR/$k ; sed "s|$SEARCHTEXT2|$FASTADIR|g" $LDIR/$PARAMFILE > $WRITEDIR/$k/$PARAMFILE.tmp1 ; sed "s|$SEARCHTEXT|$LDIR/$WRITEDIR/$k/$j|"  $WRITEDIR/$k/$PARAMFILE.tmp1 > $WRITEDIR/$k/$PARAMFILE.tmp2 ; sed "s|$SEARCHTEXT4|$thrMS|g"  $WRITEDIR/$k/$PARAMFILE.tmp2 > $WRITEDIR/$k/$PARAMFILE.tmp3 ; sed "s|$SEARCHTEXT3|$LDIR/$WRITEDIR/$k|"  $WRITEDIR/$k/$PARAMFILE.tmp3 > $WRITEDIR/$k/$k.xml ; rm $WRITEDIR/$k/$PARAMFILE.tmp*  ;done
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

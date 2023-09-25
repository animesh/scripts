#git checkout 7243207be51cffa7633344530419e2790d382afb scratch.slurm slurmTM.sh
#dos2unix scratch.slurm slurmTM.sh
#bash slurmTM.sh /cluster/home/ash022/scripts/TK
DATADIR=$1
RUNCMD=trimmomatic
PARAMFILE=scratch.slurm
CURRENTEPOCTIME=`date +%s`
WRITEDIR=$RUNCMD.$CURRENTEPOCTIME.results
mkdir $DATADIR/$WRITEDIR
for i in $DATADIR/*1.fq.gz ; do echo $i; i2=${i/%1.fq.gz/2.fq.gz} ; echo $i2; j=$(basename $i); echo $j; k=${j%%1.fq*}; echo  $k ; sed "s|seqRNA|$k.$RUNCMD|g" $PARAMFILE > $DATADIR/$WRITEDIR/$PARAMFILE.tmp1 ; 	sed "s|P1FASTFILE|$i|g"  $DATADIR/$WRITEDIR/$PARAMFILE.tmp1 > $DATADIR/$WRITEDIR/$PARAMFILE.tmp2 ;  sed "s|P2FASTFILE|$i2|g"  $DATADIR/$WRITEDIR/$PARAMFILE.tmp2 > $DATADIR/$WRITEDIR/$PARAMFILE.tmp3 ;  sed "s|PD1FASTFILE|$DATADIR/$WRITEDIR/$k|g"  $DATADIR/$WRITEDIR/$PARAMFILE.tmp3 > $DATADIR/$WRITEDIR/$PARAMFILE.tmp4 ;  sed "s|PD2FASTFILE|$DATADIR/$WRITEDIR/$k|g"  $DATADIR/$WRITEDIR/$PARAMFILE.tmp4 > $DATADIR/$WRITEDIR/$PARAMFILE.tmp5 ;  sed "s|FASTFILE|$DATADIR/$WRITEDIR/$k|g"  $DATADIR/$WRITEDIR/$PARAMFILE.tmp5 > $DATADIR/$WRITEDIR/$k.$PARAMFILE ; rm $DATADIR/$WRITEDIR/$PARAMFILE.tmp*  ; cat $DATADIR/$WRITEDIR/$k.$PARAMFILE ; echo $DATADIR/$WRITEDIR/$k.$PARAMFILE  ; sbatch $DATADIR/$WRITEDIR/$k.$PARAMFILE  ; done
echo $DATADIR/$WRITEDIR

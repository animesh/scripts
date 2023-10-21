#git checkout 119d313328587684637b161d95a06c140bebe3e0 slurmTM.sh scratch.slurm
#dos2unix scratch.slurm slurmTM.sh
#bash slurmTM.sh $PWD/TK9
DATADIR=$1
RUNCMD=trimmomatic
PARAMFILE=scratch.slurm
CURRENTEPOCTIME=`date +%s`
WRITEDIR=$RUNCMD.$CURRENTEPOCTIME.results
mkdir $DATADIR/$WRITEDIR
for i in $DATADIR/*1.fastq.gz ; do echo $i; i2=${i/%1.fastq.gz/2.fastq.gz} ; echo $i2; j=$(basename $i); echo $j; k=${j%%1.fastq*}; echo  $k ; sed "s|seqRNA|$k.$RUNCMD|g" $PARAMFILE > $DATADIR/$WRITEDIR/$PARAMFILE.tmp1 ; 	sed "s|P1FASTFILE|$i|g"  $DATADIR/$WRITEDIR/$PARAMFILE.tmp1 > $DATADIR/$WRITEDIR/$PARAMFILE.tmp2 ;  sed "s|P2FASTFILE|$i2|g"  $DATADIR/$WRITEDIR/$PARAMFILE.tmp2 > $DATADIR/$WRITEDIR/$PARAMFILE.tmp3 ;  sed "s|PD1FASTFILE|$DATADIR/$WRITEDIR/$k|g"  $DATADIR/$WRITEDIR/$PARAMFILE.tmp3 > $DATADIR/$WRITEDIR/$PARAMFILE.tmp4 ;  sed "s|PD2FASTFILE|$DATADIR/$WRITEDIR/$k|g"  $DATADIR/$WRITEDIR/$PARAMFILE.tmp4 > $DATADIR/$WRITEDIR/$PARAMFILE.tmp5 ;  sed "s|FASTFILE|$DATADIR/$WRITEDIR/$k|g"  $DATADIR/$WRITEDIR/$PARAMFILE.tmp5 > $DATADIR/$WRITEDIR/$k.$PARAMFILE ; rm $DATADIR/$WRITEDIR/$PARAMFILE.tmp*  ; cat $DATADIR/$WRITEDIR/$k.$PARAMFILE ; echo $DATADIR/$WRITEDIR/$k.$PARAMFILE  ; sbatch $DATADIR/$WRITEDIR/$k.$PARAMFILE  ; done
echo $DATADIR/$WRITEDIR

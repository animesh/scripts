#git checkout def35f5515d2a6bb0c49b9952a4c9a844a7bb73a scratch.slurm slurmQI.sh
#dos2unix scratch.slurm slurmQI.sh
#bash slurmQI.sh  $PWD/TK/hisat2.1690116069.results/samtools.1690538848.results
DATADIR=$1
RUNCMD=qualimap
PARAMFILE=scratch.slurm
CPU=20
CURRENTEPOCTIME=`date +%s`
WRITEDIR=$RUNCMD.$CURRENTEPOCTIME.results
mkdir $DATADIR/$WRITEDIR
for i in $DATADIR/*sort*bam ; do echo $i; j=$(basename $i); k=${j%%.bam}; echo  $k ; sed "s|seqRNA|$k.$RUNCMD.$CPU|g" $PARAMFILE > $DATADIR/$WRITEDIR/$PARAMFILE.tmp1 ; 	sed "s|SORTBAMFILE|$i|"  $DATADIR/$WRITEDIR/$PARAMFILE.tmp1 > $DATADIR/$WRITEDIR/$PARAMFILE.tmp2 ; sed "s|OUTDIR|$DATADIR/$WRITEDIR/$k|"  $DATADIR/$WRITEDIR/$PARAMFILE.tmp2 > $DATADIR/$WRITEDIR/$PARAMFILE.tmp3 ; sed "s|NCPU|$CPU|g"  $DATADIR/$WRITEDIR/$PARAMFILE.tmp3 > $DATADIR/$WRITEDIR/$k.$PARAMFILE ;   rm $DATADIR/$WRITEDIR/$PARAMFILE.tmp*  ; cat $DATADIR/$WRITEDIR/$k.$PARAMFILE ; echo $DATADIR/$WRITEDIR/$k.$PARAMFILE ; sbatch $DATADIR/$WRITEDIR/$k.$PARAMFILE  ;   done
echo $DATADIR/$WRITEDIR
tail -f  $DATADIR/$WRITEDIR/*log


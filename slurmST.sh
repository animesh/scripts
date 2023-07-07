#git checkout 0cf41e42d18d0da31feed531324412b0d7a7288b scratch.slurm slurmST.sh
#dos2unix scratch.slurm slurmST.sh#perl -pi -e's/\015\012/\012/g' slurmST.sh
#bash slurmST.sh $PWD/AYU/hisat2.1688724920.results
DATADIR=$1
RUNCMD=samtools
PARAMFILE=scratch.slurm
CPU=40
CURRENTEPOCTIME=`date +%s`
WRITEDIR=$RUNCMD.$CURRENTEPOCTIME.results
mkdir $DATADIR/$WRITEDIR
for i in $DATADIR/*.sam ; do echo $i; j=$(basename $i); k=${j%%.sam*}; echo  $k ; sed "s|seqRNA|$k.$RUNCMD.$CPU|g" $PARAMFILE > $DATADIR/$WRITEDIR/$PARAMFILE.tmp1 ; 	sed "s|SAMFILE|$i|"  $DATADIR/$WRITEDIR/$PARAMFILE.tmp1 > $DATADIR/$WRITEDIR/$PARAMFILE.tmp2 ; sed "s|BAMFILE|$DATADIR/$WRITEDIR/$k.bam|"  $DATADIR/$WRITEDIR/$PARAMFILE.tmp2 > $DATADIR/$WRITEDIR/$PARAMFILE.tmp3 ; sed "s|SORTBAMFILE|$DATADIR/$WRITEDIR/$k.sort.bam|g"  $DATADIR/$WRITEDIR/$PARAMFILE.tmp3 > $DATADIR/$WRITEDIR/$k.$PARAMFILE ; rm $DATADIR/$WRITEDIR/$PARAMFILE.tmp*  ; cat $DATADIR/$WRITEDIR/$k.$PARAMFILE ; echo $DATADIR/$WRITEDIR/$k.$PARAMFILE  ; sbatch $DATADIR/$WRITEDIR/$k.$PARAMFILE  ; done
echo $DATADIR/$WRITEDIR


#git checkout 53b672d5f9da4ac8bef8076cd54f91a1b8916fe0 scratch.slurm slurmST.sh
#dos2unix scratch.slurm slurmST.sh
#bash slurmST.sh $PWD/TK9/trimmomatic.1701618021.results/hisat2.1701897177.results
#bash slurmST.sh $PWD/TK9/trimmomatic.1701608001.results/hisat2.1701618338.results
#bash slurmST.sh $PWD/TK9/trimmomatic.1701608001.results/hisat2.1701896943.results
DATADIR=$1
RUNCMD=samtools
PARAMFILE=scratch.slurm
CPU=10
CURRENTEPOCTIME=`date +%s`
WRITEDIR=$RUNCMD.$CURRENTEPOCTIME.results
mkdir $DATADIR/$WRITEDIR
for i in $DATADIR/*.?am ; do echo $i; j=$(basename $i); k=${j%%.?am*}; echo  $k ; sed "s|seqRNA|$k.$RUNCMD.$CPU|g" $PARAMFILE > $DATADIR/$WRITEDIR/$PARAMFILE.tmp1 ; 	sed "s|SAMFILE|$i|g"  $DATADIR/$WRITEDIR/$PARAMFILE.tmp1 > $DATADIR/$WRITEDIR/$PARAMFILE.tmp2 ; sed "s|BAMFILE|$DATADIR/$WRITEDIR/$k.bam|"  $DATADIR/$WRITEDIR/$PARAMFILE.tmp2 > $DATADIR/$WRITEDIR/$PARAMFILE.tmp3 ; sed "s|SORTBAMFILE|$DATADIR/$WRITEDIR/$k.sort.bam|"  $DATADIR/$WRITEDIR/$PARAMFILE.tmp3 > $DATADIR/$WRITEDIR/$PARAMFILE.tmp4 ; sed "s|INDEXSORT|$DATADIR/$WRITEDIR/$k.sort.bam|"  $DATADIR/$WRITEDIR/$PARAMFILE.tmp4 > $DATADIR/$WRITEDIR/$PARAMFILE.tmp5 ;  sed "s|NCPU|$CPU|g"  $DATADIR/$WRITEDIR/$PARAMFILE.tmp5 > $DATADIR/$WRITEDIR/$k.$PARAMFILE ;   rm $DATADIR/$WRITEDIR/$PARAMFILE.tmp*  ; cat $DATADIR/$WRITEDIR/$k.$PARAMFILE ; echo $DATADIR/$WRITEDIR/$k.$PARAMFILE  ; sbatch $DATADIR/$WRITEDIR/$k.$PARAMFILE  ; done


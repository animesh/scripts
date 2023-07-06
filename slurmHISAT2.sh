#perl -pi -e's/\015\012/\012/g' slurmHISAT2.sh
#bash slurmHISAT2.sh /cluster/projects/nn9036k/rnaSeqChk /cluster/projects/nn9036k/rnaSeqChk/grch38_tran/genome_tran
DATADIR=$1
MAPFILE=$2
RUNCMD=hisat2
PARAMFILE=scratch.slurm
CPU=40
CURRENTEPOCTIME=`date +%s`
WRITEDIR=$RUNCMD.$CURRENTEPOCTIME.results
mkdir $DATADIR/$WRITEDIR
for i in $DATADIR/*fastq.gz ; do echo $i; j=$(basename $i); k=${j%%.fastq*}; echo  $k ; sed "s|seqRNA|$k|g" $PARAMFILE > $DATADIR/$WRITEDIR/$PARAMFILE.tmp1 ; 	sed "s|FASTFILE|$i|"  $DATADIR/$WRITEDIR/$PARAMFILE.tmp1 > $DATADIR/$WRITEDIR/$PARAMFILE.tmp2 ; sed "s|FASTFILE|$DATADIR/$WRITEDIR/$k|g"  $DATADIR/$WRITEDIR/$PARAMFILE.tmp2 > $DATADIR/$WRITEDIR/$PARAMFILE.tmp3 ; sed "s|HISATGENOMEDIR|$MAPFILE|g"  $DATADIR/$WRITEDIR/$PARAMFILE.tmp3 > $DATADIR/$WRITEDIR/$k.$PARAMFILE ; rm $DATADIR/$WRITEDIR/$PARAMFILE.tmp*  ; cat $DATADIR/$WRITEDIR/$k.$PARAMFILE ; echo $DATADIR/$WRITEDIR/$k.$PARAMFILE  ; sbatch $DATADIR/$WRITEDIR/$k.$PARAMFILE  ; done



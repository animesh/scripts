#git checkout d7f942ab93fed3168416a60ee87adad277f71d94 slurmHISAT2.sh scratch.slurm
#dos2unix slurmHISAT2.sh scratch.slurm#perl -pi -e's/\015\012/\012/g' slurmHISAT2.sh
#bash slurmHISAT2.sh $PWD/AYU /cluster/projects/nn9036k/rnaSeqChk/grch38_tran/genome_tran
DATADIR=$1
MAPFILE=$2
RUNCMD=hisat2
PARAMFILE=scratch.slurm
CPU=40
CURRENTEPOCTIME=`date +%s`
WRITEDIR=$RUNCMD.$CURRENTEPOCTIME.results
mkdir $DATADIR/$WRITEDIR
for i in $DATADIR/*1.fq.gz ; do echo $i; i2=${i/%1.fq/2.fq} ; echo $i2; j=$(basename $i); echo $j; k=${j%%1.fq*}; echo  $k ; sed "s|seqRNA|$k.$RUNCMD.$CPU|g" $PARAMFILE > $DATADIR/$WRITEDIR/$PARAMFILE.tmp1 ; 	sed "s|FASTFILE1|$i|"  $DATADIR/$WRITEDIR/$PARAMFILE.tmp1 > $DATADIR/$WRITEDIR/$PARAMFILE.tmp2 ;  sed "s|FASTFILE2|$i2|"  $DATADIR/$WRITEDIR/$PARAMFILE.tmp2 > $DATADIR/$WRITEDIR/$PARAMFILE.tmp3 ;  sed "s|FASTFILE|$DATADIR/$WRITEDIR/$k|g"  $DATADIR/$WRITEDIR/$PARAMFILE.tmp3 > $DATADIR/$WRITEDIR/$PARAMFILE.tmp4 ; sed "s|HISATGENOMEDIR|$MAPFILE|g"  $DATADIR/$WRITEDIR/$PARAMFILE.tmp4 > $DATADIR/$WRITEDIR/$k.$PARAMFILE ; rm $DATADIR/$WRITEDIR/$PARAMFILE.tmp*  ; cat $DATADIR/$WRITEDIR/$k.$PARAMFILE ; echo $DATADIR/$WRITEDIR/$k.$PARAMFILE  ; sbatch $DATADIR/$WRITEDIR/$k.$PARAMFILE  ; done
echo $DATADIR/$WRITEDIR


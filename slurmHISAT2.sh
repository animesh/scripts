#git checkout d0c2421846c29bbb3facddd46b16511f4537649b scratch.slurm
#dos2unix slurmHISAT2.sh scratch.slurm
#mkdir TK9trim
#ln -s $PWD/TK9/trimmomatic.1697725340.results/*P.fq.gz TK9trim/.
#cd TK9trim/
#rename 'P.fq.gz' '.fq.gz' *
#rename 'R.' 'R' *
#rename 'fq.gz' 'fastq.gz' *
#cd ..
#cat slurmHISAT2.sh
#bash slurmHISAT2.sh $PWD/TK9trim /cluster/projects/nn9036k/rnaSeqChk/grch38_tran/genome_tran
DATADIR=$1
MAPFILE=$2
RUNCMD=hisat2
PARAMFILE=scratch.slurm
CPU=40
CURRENTEPOCTIME=`date +%s`
WRITEDIR=$RUNCMD.$CURRENTEPOCTIME.results
mkdir $DATADIR/$WRITEDIR
for i in $DATADIR/*1.fastq* ; do echo $i; i2=${i/%1.fastq/2.fastq} ; echo $i2; j=$(basename $i); echo $j; k=${j%%1.fastq*}; echo  $k ; sed "s|seqRNA|$k.$RUNCMD.$CPU|g" $PARAMFILE > $DATADIR/$WRITEDIR/$PARAMFILE.tmp1 ; 	sed "s|FASTFILE1|$i|"  $DATADIR/$WRITEDIR/$PARAMFILE.tmp1 > $DATADIR/$WRITEDIR/$PARAMFILE.tmp2 ;  sed "s|FASTFILE2|$i2|"  $DATADIR/$WRITEDIR/$PARAMFILE.tmp2 > $DATADIR/$WRITEDIR/$PARAMFILE.tmp3 ;  sed "s|FASTFILE|$DATADIR/$WRITEDIR/$k|g"  $DATADIR/$WRITEDIR/$PARAMFILE.tmp3 > $DATADIR/$WRITEDIR/$PARAMFILE.tmp4 ; sed "s|HISATGENOMEDIR|$MAPFILE|g"  $DATADIR/$WRITEDIR/$PARAMFILE.tmp4 > $DATADIR/$WRITEDIR/$k.$PARAMFILE ; rm $DATADIR/$WRITEDIR/$PARAMFILE.tmp*  ; cat $DATADIR/$WRITEDIR/$k.$PARAMFILE ; echo $DATADIR/$WRITEDIR/$k.$PARAMFILE  ; sbatch $DATADIR/$WRITEDIR/$k.$PARAMFILE  ; done
echo $DATADIR/$WRITEDIR


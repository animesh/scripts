#bash idxGen.sh
#git checkout 069e21a60b8255c8e0c493413565ace1b92e84e3 scratch.slurm slurmSTAR.sh
#dos2unix scratch.slurm slurmSTAR.sh
#bash slurmSTAR.sh $PWD/TK $PWD/CHM13v2-T2T/index_len150
DATADIR=$1
MAPFILE=$2
RUNCMD=star
PARAMFILE=scratch.slurm
CPU=40
CURRENTEPOCTIME=`date +%s`
WRITEDIR=$RUNCMD.$CURRENTEPOCTIME.results
mkdir $DATADIR/$WRITEDIR
for i in $DATADIR/*1.fq.gz ; do echo $i; i2=${i/%1.fq.gz/2.fq.gz} ; echo $i2; j=$(basename $i); echo $j; k=${j%%1.fq*}; echo  $k ; sed "s|seqRNA|$k.$RUNCMD.$CPU|g" $PARAMFILE > $DATADIR/$WRITEDIR/$PARAMFILE.tmp1 ; 	sed "s|FASTFILE1|$i|"  $DATADIR/$WRITEDIR/$PARAMFILE.tmp1 > $DATADIR/$WRITEDIR/$PARAMFILE.tmp2 ;  sed "s|FASTFILE2|$i2|"  $DATADIR/$WRITEDIR/$PARAMFILE.tmp2 > $DATADIR/$WRITEDIR/$PARAMFILE.tmp3 ;  sed "s|FASTFILE|$DATADIR/$WRITEDIR/$k|g"  $DATADIR/$WRITEDIR/$PARAMFILE.tmp3 > $DATADIR/$WRITEDIR/$PARAMFILE.tmp4 ; sed "s|STARGENOMEDIR|$MAPFILE|g"  $DATADIR/$WRITEDIR/$PARAMFILE.tmp4 > $DATADIR/$WRITEDIR/$k.$PARAMFILE ; rm $DATADIR/$WRITEDIR/$PARAMFILE.tmp*  ; cat $DATADIR/$WRITEDIR/$k.$PARAMFILE ; echo $DATADIR/$WRITEDIR/$k.$PARAMFILE  ; sbatch $DATADIR/$WRITEDIR/$k.$PARAMFILE  ; done
echo $DATADIR/$WRITEDIR
tail -f $$DATADIR/$WRITEDIR/*Log.progress.out
#tail -f TK/star.1691068198.results/*Log.progress.out

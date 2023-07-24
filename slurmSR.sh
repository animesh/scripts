#git checkout 71a2f5b100d3cc6c3e543098d234ebaafdd88d4e slurmSR.sh
#dos2unix slurmSR.sh
#bash slurmSR.sh hg38v110/Homo_sapiens.GRCh38.110.gtf TK/hisat2.1689928244.results/samtools.1689938696.results
RUNCMD=subread
MAPFILE=$1
mfj=$(basename $MAPFILE); 
mfk=${mfj%%.gtf*}
DATADIR=$2
PARAMFILE=scratch.slurm
SORTBAMFILES=$(ls $DATADIR/*.sort*.bam |tr "\n" " ")
CPU=$(echo $SORTBAMFILES | wc | awk '{print $2}')
CURRENTEPOCTIME=`date +%s`
WRITEDIR=$RUNCMD.$CURRENTEPOCTIME.results
echo $MAPFILE $mfj $DATADIR $WRITEDIR $SORTBAMFILES
mkdir $DATADIR/$WRITEDIR
#featureCounts -T $CPU  -t exon -g gene_id -O -a $MAPFILE -o $DATADIR/$WRITEDIR/$mfk.$CPU.counts.txt $SORTBAMFILES
sed "s|SLURMJOB|A.$RUNCMD.$mfk.$CPU|g" $PARAMFILE > $DATADIR/$WRITEDIR/countA.$PARAMFILE.tmp
sed "s|NCPU|$CPU|g" $DATADIR/$WRITEDIR/countA.$PARAMFILE.tmp  > $DATADIR/$WRITEDIR/countA.$PARAMFILE
echo "module purge" >> $DATADIR/$WRITEDIR/countA.$PARAMFILE
echo "module load Subread/2.0.3-GCC-11.2.0" >> $DATADIR/$WRITEDIR/countA.$PARAMFILE

echo "featureCounts -T $CPU -p -t exon -g gene_id -O -a $MAPFILE -o $DATADIR/$WRITEDIR/$mfk.$CPU.count.txt $SORTBAMFILES" >> $DATADIR/$WRITEDIR/countA.$PARAMFILE
cat $DATADIR/$WRITEDIR/countA.$PARAMFILE
echo $DATADIR/$WRITEDIR/countA.$PARAMFILE
sbatch $DATADIR/$WRITEDIR/countA.$PARAMFILE
#pairs
sed "s|SLURMJOB|P.$RUNCMD.$mfk.$CPU|g" $PARAMFILE > $DATADIR/$WRITEDIR/countP.$PARAMFILE.tmp
sed "s|NCPU|$CPU|g" $DATADIR/$WRITEDIR/countP.$PARAMFILE.tmp  > $DATADIR/$WRITEDIR/countP.$PARAMFILE
echo "module purge" >> $DATADIR/$WRITEDIR/countP.$PARAMFILE
echo "module load Subread/2.0.3-GCC-11.2.0" >> $DATADIR/$WRITEDIR/countP.$PARAMFILE

echo "featureCounts -T $CPU -p --countReadPairs -C -t exon -g gene_id -O -a $MAPFILE -o $DATADIR/$WRITEDIR/$mfk.$CPU.countOnlyPairs.txt $SORTBAMFILES" >> $DATADIR/$WRITEDIR/countP.$PARAMFILE

cat $DATADIR/$WRITEDIR/countP.$PARAMFILE
echo $DATADIR/$WRITEDIR/countP.$PARAMFILE
sbatch $DATADIR/$WRITEDIR/countP.$PARAMFILE


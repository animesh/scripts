#git checkout 71a2f5b100d3cc6c3e543098d234ebaafdd88d4e slurmSR.sh
#dos2unix slurmSR.sh
#bash slurmSR.sh hg38v110/Homo_sapiens.GRCh38.110.gtf TK/hisat2.1689928244.results/samtools.1689938696.results
RUNCMD=subread
MAPFILE=$1
mfj=$(basename $MAPFILE); 
mfk=${mfj%%.gtf*}
DATADIR=$2
PARAMFILE=scratch.slurm
CPU=40
CURRENTEPOCTIME=`date +%s`
WRITEDIR=$RUNCMD.$CURRENTEPOCTIME.results
SORTBAMFILES=$(ls $DATADIR/*.sort.bam |tr "\n" " ")
echo $MAPFILE $mfj $DATADIR $WRITEDIR $SORTBAMFILES
mkdir $DATADIR/$WRITEDIR
#featureCounts -T $CPU  -t exon -g gene_id -O -a $MAPFILE -o $DATADIR/$WRITEDIR/$mfk.$CPU.counts.txt $SORTBAMFILES
sed "s|SLURMJOB|$RUNCMD.$mfk.$CPU|g" $PARAMFILE > $DATADIR/$WRITEDIR/$PARAMFILE
echo "module purge" >> $DATADIR/$WRITEDIR/$PARAMFILE
echo "module load Subread/2.0.3-GCC-11.2.0" >> $DATADIR/$WRITEDIR/$PARAMFILE

echo "featureCounts -T $CPU -p -t exon -g gene_id -O -a $MAPFILE -o $DATADIR/$WRITEDIR/$mfk.$CPU.count.txt $SORTBAMFILES" >> $DATADIR/$WRITEDIR/$PARAMFILE
echo "featureCounts -T $CPU -p --countReadPairs -C -t exon -g gene_id -O -a $MAPFILE -o $DATADIR/$WRITEDIR/$mfk.$CPU.countOnlyPairs.txt $SORTBAMFILES" >> $DATADIR/$WRITEDIR/$PARAMFILE
cat $DATADIR/$WRITEDIR/$PARAMFILE
echo $DATADIR/$WRITEDIR/$PARAMFILE
sbatch $DATADIR/$WRITEDIR/$PARAMFILE
echo $DATADIR/$WRITEDIR/$mfk.$CPU.countWithPairs.txt

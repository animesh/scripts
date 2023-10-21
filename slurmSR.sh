#git checkout 8c9b98c1ef58fa67355743da3bf78516467fd85f scratch.slurm slurmSR.sh
#dos2unix  scratch.slurm slurmSR.sh
#cat slurmSR.sh
#ls -ltrh /cluster/projects/nn9036k/scripts/TK/mergeHISAT/ >> slurmSR.sh
#bash slurmSR.sh hg38v110/Homo_sapiens.GRCh38.110.gtf /cluster/projects/nn9036k/scripts/TK/mergeHISAT 
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

#lrwxrwxr-x 1 ash022 nn9036k 145 Oct 21 10:33 TK9_1L6_R.sort.bam -> /cluster/projects/nn9036k/scripts/TK9/hisat2.1697716972.results/samtools.1697718610.results/TK9_1_22FFLLLT3_AGAGAACCTA-GGTTATGCTA_L006_R.sort.bam
#lrwxrwxr-x 1 ash022 nn9036k 145 Oct 21 10:33 TK9_1L5_R.sort.bam -> /cluster/projects/nn9036k/scripts/TK9/hisat2.1697716972.results/samtools.1697718610.results/TK9_1_22FFLLLT3_AGAGAACCTA-GGTTATGCTA_L005_R.sort.bam
#lrwxrwxr-x 1 ash022 nn9036k 145 Oct 21 10:33 TK9_2L6_R.sort.bam -> /cluster/projects/nn9036k/scripts/TK9/hisat2.1697716972.results/samtools.1697718610.results/TK9_2_22FFLLLT3_GATATTGTGT-ACCACACGGT_L006_R.sort.bam
#lrwxrwxr-x 1 ash022 nn9036k 145 Oct 21 10:33 TK9_2L5_R.sort.bam -> /cluster/projects/nn9036k/scripts/TK9/hisat2.1697716972.results/samtools.1697718610.results/TK9_2_22FFLLLT3_GATATTGTGT-ACCACACGGT_L005_R.sort.bam
#lrwxrwxr-x 1 ash022 nn9036k 145 Oct 21 10:33 TK9_3L5_R.sort.bam -> /cluster/projects/nn9036k/scripts/TK9/hisat2.1697716972.results/samtools.1697718610.results/TK9_3_22FFLLLT3_CGTACAGGAA-TAGGTTCTCT_L005_R.sort.bam
#lrwxrwxr-x 1 ash022 nn9036k 145 Oct 21 10:33 TK9_3L6_R.sort.bam -> /cluster/projects/nn9036k/scripts/TK9/hisat2.1697716972.results/samtools.1697718610.results/TK9_3_22FFLLLT3_CGTACAGGAA-TAGGTTCTCT_L006_R.sort.bam
#lrwxrwxr-x 1 ash022 nn9036k 108 Oct 21 13:06 TK10_51_.sort.bam -> /cluster/projects/nn9036k/scripts/TK/hisat2.1690116069.results/samtools.1690117388.results/TK10_51_.sort.bam
#lrwxrwxr-x 1 ash022 nn9036k 108 Oct 21 13:06 TK10_50_.sort.bam -> /cluster/projects/nn9036k/scripts/TK/hisat2.1690116069.results/samtools.1690117388.results/TK10_50_.sort.bam
#lrwxrwxr-x 1 ash022 nn9036k 108 Oct 21 13:06 TK10_49_.sort.bam -> /cluster/projects/nn9036k/scripts/TK/hisat2.1690116069.results/samtools.1690117388.results/TK10_49_.sort.bam
#lrwxrwxr-x 1 ash022 nn9036k 108 Oct 21 13:06 TK16_R3_.sort.bam -> /cluster/projects/nn9036k/scripts/TK/hisat2.1690116069.results/samtools.1690117388.results/TK16_R3_.sort.bam
#lrwxrwxr-x 1 ash022 nn9036k 108 Oct 21 13:06 TK16_R2_.sort.bam -> /cluster/projects/nn9036k/scripts/TK/hisat2.1690116069.results/samtools.1690117388.results/TK16_R2_.sort.bam
#lrwxrwxr-x 1 ash022 nn9036k 108 Oct 21 13:06 TK16_R1_.sort.bam -> /cluster/projects/nn9036k/scripts/TK/hisat2.1690116069.results/samtools.1690117388.results/TK16_R1_.sort.bam
#lrwxrwxr-x 1 ash022 nn9036k 107 Oct 21 13:06 TK14_3_.sort.bam -> /cluster/projects/nn9036k/scripts/TK/hisat2.1690116069.results/samtools.1690117388.results/TK14_3_.sort.bam
#lrwxrwxr-x 1 ash022 nn9036k 107 Oct 21 13:06 TK14_2_.sort.bam -> /cluster/projects/nn9036k/scripts/TK/hisat2.1690116069.results/samtools.1690117388.results/TK14_2_.sort.bam
#lrwxrwxr-x 1 ash022 nn9036k 107 Oct 21 13:06 TK14_1_.sort.bam -> /cluster/projects/nn9036k/scripts/TK/hisat2.1690116069.results/samtools.1690117388.results/TK14_1_.sort.bam
#lrwxrwxr-x 1 ash022 nn9036k 107 Oct 21 13:06 TK13_3_.sort.bam -> /cluster/projects/nn9036k/scripts/TK/hisat2.1690116069.results/samtools.1690117388.results/TK13_3_.sort.bam
#lrwxrwxr-x 1 ash022 nn9036k 107 Oct 21 13:06 TK13_2_.sort.bam -> /cluster/projects/nn9036k/scripts/TK/hisat2.1690116069.results/samtools.1690117388.results/TK13_2_.sort.bam
#lrwxrwxr-x 1 ash022 nn9036k 107 Oct 21 13:06 TK13_1_.sort.bam -> /cluster/projects/nn9036k/scripts/TK/hisat2.1690116069.results/samtools.1690117388.results/TK13_1_.sort.bam
#lrwxrwxr-x 1 ash022 nn9036k 108 Oct 21 13:06 TK12_R3_.sort.bam -> /cluster/projects/nn9036k/scripts/TK/hisat2.1690116069.results/samtools.1690117388.results/TK12_R3_.sort.bam
#lrwxrwxr-x 1 ash022 nn9036k 108 Oct 21 13:06 TK12_R2_.sort.bam -> /cluster/projects/nn9036k/scripts/TK/hisat2.1690116069.results/samtools.1690117388.results/TK12_R2_.sort.bam
#lrwxrwxr-x 1 ash022 nn9036k 108 Oct 21 13:06 TK12_R1_.sort.bam -> /cluster/projects/nn9036k/scripts/TK/hisat2.1690116069.results/samtools.1690117388.results/TK12_R1_.sort.bam
#lrwxrwxr-x 1 ash022 nn9036k 108 Oct 21 13:06 TK18_R3_.sort.bam -> /cluster/projects/nn9036k/scripts/TK/hisat2.1690116069.results/samtools.1690117388.results/TK18_R3_.sort.bam
#lrwxrwxr-x 1 ash022 nn9036k 108 Oct 21 13:06 TK18_R2_.sort.bam -> /cluster/projects/nn9036k/scripts/TK/hisat2.1690116069.results/samtools.1690117388.results/TK18_R2_.sort.bam
#lrwxrwxr-x 1 ash022 nn9036k 108 Oct 21 13:06 TK18_R1_.sort.bam -> /cluster/projects/nn9036k/scripts/TK/hisat2.1690116069.results/samtools.1690117388.results/TK18_R1_.sort.bam
#lrwxrwxr-x 1 ash022 nn9036k 149 Oct 21 22:29 TK9_1Ltrim5_R.sort.bam -> /cluster/projects/nn9036k/scripts/TK9trim/hisat2.1697881193.results/samtools.1697919237.results/TK9_1_22FFLLLT3_AGAGAACCTA-GGTTATGCTA_L005_R.sort.bam
#lrwxrwxr-x 1 ash022 nn9036k 149 Oct 21 22:29 TK9_3Ltrim6_R.sort.bam -> /cluster/projects/nn9036k/scripts/TK9trim/hisat2.1697881193.results/samtools.1697919237.results/TK9_3_22FFLLLT3_CGTACAGGAA-TAGGTTCTCT_L006_R.sort.bam
#lrwxrwxr-x 1 ash022 nn9036k 149 Oct 21 22:29 TK9_3Ltrim5_R.sort.bam -> /cluster/projects/nn9036k/scripts/TK9trim/hisat2.1697881193.results/samtools.1697919237.results/TK9_3_22FFLLLT3_CGTACAGGAA-TAGGTTCTCT_L005_R.sort.bam
#lrwxrwxr-x 1 ash022 nn9036k 149 Oct 21 22:29 TK9_2Ltrim6_R.sort.bam -> /cluster/projects/nn9036k/scripts/TK9trim/hisat2.1697881193.results/samtools.1697919237.results/TK9_2_22FFLLLT3_GATATTGTGT-ACCACACGGT_L006_R.sort.bam
#lrwxrwxr-x 1 ash022 nn9036k 149 Oct 21 22:29 TK9_2Ltrim5_R.sort.bam -> /cluster/projects/nn9036k/scripts/TK9trim/hisat2.1697881193.results/samtools.1697919237.results/TK9_2_22FFLLLT3_GATATTGTGT-ACCACACGGT_L005_R.sort.bam
#lrwxrwxr-x 1 ash022 nn9036k 149 Oct 21 22:29 TK9_1Ltrim6_R.sort.bam -> /cluster/projects/nn9036k/scripts/TK9trim/hisat2.1697881193.results/samtools.1697919237.results/TK9_1_22FFLLLT3_AGAGAACCTA-GGTTATGCTA_L006_R.sort.bam

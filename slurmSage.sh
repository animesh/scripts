#git checkout 8c9b98c1ef58fa67355743da3bf78516467fd85f scratch.slurm slurmSR.sh
#dos2unix  scratch.slurm slurmSR.sh
#cat slurmSR.sh
#ls -ltrh /cluster/projects/nn9036k/scripts/TK/mergeHISAT/ >> slurmSR.sh
#bash slurmSR.sh hg38v110/Homo_sapiens.GRCh38.110.gtf /cluster/projects/nn9036k/scripts/TK/mergeHISAT
# 1005  2023-11-03T10:11:26 wget "https://objects.githubusercontent.com/github-production-release-asset-2e65be/515039720/c96dc732-3f5e-4e0f-bb44-221bdbd32a97?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20231103%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20231103T090944Z&X-Amz-Expires=300&X-Amz-Signature=9fadc5fa59440dbe3db96efa921cb40e17df89a17e36c3d1e88a1003ab577c14&X-Amz-SignedHeaders=host&actor_id=21457&key_id=0&repo_id=515039720&response-content-disposition=attachment%3B%20filename%3Dsage-v0.14.4-x86_64-unknown-linux-gnu.tar.gz&response-content-type=application%2Foctet-stream"
# 1006  2023-11-03T10:11:51 mv c96dc732-3f5e-4e0f-bb44-221bdbd32a97\?X-Amz-Algorithm\=AWS4-HMAC-SHA256\&X-Amz-Credential\=AKIAIWNJYAX4CSVEH53A%2F20231103%2Fus-east-1%2Fs3%2Faws4_request\&X-Amz-Date\=20231103T090944Z\&X-Amz-Expires\=300\&X-Amz-Signature\=9fadc5fa59440dbe3db96ef sage.tar.gz
# 1007  2023-11-03T10:11:54 tar xvzf sage.tar.gz
# 1018  2023-11-03T10:38:33 rsync -Parv login.nird-lmd.sigma2.no:HF/Lars/2022/November/solveig\ ird/PDv2p5try/TryP/*.*ML .
# 1031  2023-11-03T10:44:41 grep "rev_" /cluster/projects/nn9036k/FastaDB/2022-04-21-decoys-isoforms-contam-UP000005640.fas | wc
# 1032  2023-11-03T10:44:53 grep "^>" /cluster/projects/nn9036k/FastaDB/2022-04-21-decoys-isoforms-contam-UP000005640.fas | wc
# 1033  2023-11-03T10:45:06 vim IRD/sage.json
# 1036  2023-11-03T10:47:33 ls -ltrh IRD/231006_IRD_7_D22_T1_ddaPD.mzML
# 1040  2023-11-03T10:48:43 ./sage-v0.14.4-x86_64-unknown-linux-gnu/sage IRD/sage.json
# 1042  2023-11-03T10:52:08 wc results.sage.tsv
#cat ../MaxQuant_2.4.3.0/bin/conf/contaminants.fasta IRD/HUMAN_IRD_klon.6F.unstarXP.fasta >> IRD/human_crap_ird.fasta
RUNCMD=sage
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

#git checkout b9c1abe446bcb7bd7f94882b63f97546fcc9e0f9 scratch.slurm
#scp -r ash022@login1.nird-lmd.sigma2.no:PD/Qexactive/LARS/2015/november/Jurkat_Sudhl5\\\ SAHA\\\ B2_3/*.raw .
#bash slurmFP.sh $PWD/saha /cluster/projects/nn9036k/FastaDB/2022-04-21-decoys-isoforms-contam-UP000005640.fas scratch.slurm fp.workflow.txt
DATADIR=$1
FASTA=$2
SLURM=$3
WORKFLOW=$4
CURRENTEPOCTIME=`date +%s`
WRITEDIR=$WORKFLOW.$CURRENTEPOCTIME.results
mkdir $WRITEDIR
#perl -pe 's/\r$//' < mqrun.sh  > tmp
dos2unix $SLURM
cp -rf $DATADIR/*.raw $WRITEDIR/.
ls -ltrh $WRITEDIR/*.raw > $LOG
sed "s|FPFASTAFILE|$FASTA|" $WORKFLOW > $WRITEDIR/fp.workflow.txt
for i in $PWD/$WRITEDIR/*.raw
    do echo $i
    j=$(basename $i)
    k=${j%%.*}
    d=$PWD/$WRITEDIR/$k
    mkdir $d 
    printf "$i\t$k\t\tDDA\n" | tee $d/$k.txt
    LOG=$i.out.slurm.txt
    #touch $LOG
    cat $d/$k.txt
    sed "s|FPSLURMNAME|$k|" $SLURM > $d/$k.slurm.tmp
    sed "s|FPMANIFESTFILE|$d/$k\.txt|" $d/$k.slurm.tmp > $d/$k.slurm.tmp2
    sed "s|FPWORKDIR|$d|" $d/$k.slurm.tmp2 > $d/$k.slurm.tmp
    sed "s|FPSLURMLOG|$LOG|" $d/$k.slurm.tmp > $d/$k.slurm.tmp2
    sed "s|FPWORKFLOW|$WRITEDIR/fp.workflow.txt|" $d/$k.slurm.tmp2 > $d/$k.slurm
    ls -ltrh $d/$k.slurm
    cat $d/$k.slurm
    sbatch $d/$k.slurm
done
head -n 9 $WRITEDIR/fp.workflow.txt


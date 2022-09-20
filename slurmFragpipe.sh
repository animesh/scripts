
#git checkout bbcce483bbea5e66edb16213f3f502f135c94941 scratch.slurm
#dos2unix scratch.slurm
#bash slurmFragpipe.sh /cluster/projects/nn9036k/220908PHos/d2/ /cluster/projects/nn9036k/FastaDB/2022-04-21-decoys-isoforms-contam-UP000005640.fas scratch.slurm fp.workflow.txt out.slurm.d2.txt
DATADIR=$1
FASTA=$2
SLURM=$3
WORKFLOW=$4
LOG=$5
ls -ltrh $DATADIR/*.d > $LOG
sed "s|FPFASTAFILE|$FASTA|" $WORKFLOW > $DATADIR/fp.workflow.txt
for i in $DATADIR/*.d
    do echo $i
    j=$(basename $i)
    k=${j%%.*}
    d=$(dirname $i) 
    printf "$i\t$k\t\tDDA\n" | tee $d/$k.txt
    cat $d/$k.txt
    sed "s|FPSLURMNAME|$k|" $SLURM > slurm.tmp
    sed "s|FPMANIFESTFILE|$d\/$k\.txt|" slurm.tmp > slurm.tmp2
    sed "s|FPWORKDIR|$d\/$k|" slurm.tmp2 > slurm.tmp
    sed "s|FPSLURMLOG|$LOG|" slurm.tmp > slurm.tmp2
    sed "s|FPWORKFLOW|$d\/fp.workflow.txt|" slurm.tmp2 > $d/$k.slurm
    cat $d/$k.slurm
    sbatch $d/$k.slurm
done
head -n 9 $DATADIR/fp.workflow.txt


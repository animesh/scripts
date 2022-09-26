#git checkout bbcce483bbea5e66edb16213f3f502f135c94941 scratch.slurm
#ln -s /trd-project1/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2022/september/220926\ ida\ beate arthro
#bash slurmFragpipe.sh $PWD/arthro /cluster/projects/nn9036k/FastaDB/2022-04-10-decoys-contam-uniprot_sprot.fasta scratch.slurm fp.workflow.txt
DATADIR=$1
FASTA=$2
SLURM=$3
WORKFLOW=$4
CURRENTEPOCTIME=`date +%s`
WRITEDIR=$WORKFLOW.$CURRENTEPOCTIME.results
mkdir $WRITEDIR
#perl -pe 's/\r$//' < mqrun.sh  > tmp
dos2unix $SLURM
cp -rf $DATADIR/*.d $WRITEDIR/.
ls -ltrh $WRITEDIR/*.d > $LOG
sed "s|FPFASTAFILE|$FASTA|" $WORKFLOW > $WRITEDIR/fp.workflow.txt
for i in $PWD/$WRITEDIR/*.d
    do echo $i
    j=$(basename $i)
    k=${j%%.*}
    d=$(dirname $i) 
    printf "$i\t$k\t\tDDA\n" | tee $d/$k.txt
    LOG=$i.out.slurm.txt
    #touch $LOG
    cat $d/$k.txt
    sed "s|FPSLURMNAME|$k|" $SLURM > $d/$k.slurm.tmp
    sed "s|FPMANIFESTFILE|$d/$k\.txt|" $d/$k.slurm.tmp > $d/$k.slurm.tmp2
    sed "s|FPWORKDIR|$d/$k|" $d/$k.slurm.tmp2 > $d/$k.slurm.tmp
    sed "s|FPSLURMLOG|$LOG|" $d/$k.slurm.tmp > $d/$k.slurm.tmp2
    sed "s|FPWORKFLOW|$d/fp.workflow.txt|" $d/$k.slurm.tmp2 > $d/$k.slurm
    ls -ltrh $d/$k.slurm
    cat $d/$k.slurm
    sbatch $d/$k.slurm
done
head -n 9 $WRITEDIR/fp.workflow.txt


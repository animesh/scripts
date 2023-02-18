#git checkout 3dd1d094aa04c3af35a5ff20bb54c8d7e074257b  scratch.slurm
#cp -rf $PWD/230209_Tore_Brembu_phos/*41* $PWD/TB/.
#bash slurmFP.sh $PWD/230209_Tore_Brembu_phos /cluster/projects/nn9036k/scripts/TB/2023-02-18-decoys-contam-uniprot-Phaeodactylum_tricor_Iso__2022.12.05.TB.fasta.fas scratch.slurm fp.workflow.txt
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


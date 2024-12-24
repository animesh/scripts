#bash slurmDIANNrunTTP.sh /cluster/projects/nn9036k/scripts/salmon/dia scratch.slurm
#mkdir -p salmon/dia
#rsync -Parv ash022@login.nird-lmd.sigma2.no:PD/TIMSTOF/LARS/2024/241219_Hela_DDA_DIA/Hela_Salmon/DIA/*.d salmon/dia/.
DATADIR=$1
#leave following empty to include ALL files
CURRENTEPOCTIME=`date +%s`
echo $DATADIR.$CURRENTEPOCTIME
#date -d @1604251727
for i in $DATADIR/*.d
    do echo $i
    j=$(basename $i)
    k=${j%%.*}
    d=$(dirname $i) 
    printf "$i\t$j\t$kt\t$d\n" | tee $i.txt
    cat $i.txt
    cp scratch.slurm $i.slurm 
    sed "s|procDIANN|$k|" $i.slurm  > slurm.tmp
    sed "s|logDIANN|$i.txt|" slurm.tmp > slurm.tmp2
    sed "s|inDIANN|$i|" slurm.tmp2 > slurm.tmp
    sed "s|outDIANN|$i.$CURRENTEPOCTIME.tsv|" slurm.tmp > $i.slurm
    cat $i.slurm
    sbatch $i.slurm
done
tail -n 4 $DATADIR/*.slurm


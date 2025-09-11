#cd /cluster/home/ash022/scripts
#mkdir aleDIA 
#rsync -Parv /nird/projects/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2025/250902_Alessandro/250902_Alessandro*b_*.d aleDIA/
#bash slurmDIANN.sh /cluster/projects/nn9036k/scripts/aleDIA
#for i in $PWD/aleDIA/*.d ; do grep "TestFile.d" ; sed -i "s|TestFile\.d|$i|g" $i.slurm  ;done
DATADIR=$1
SEARCHTEXT=TestFile.d
CURRENTEPOCTIME=`date +%s`
WRITEFILE=$CURRENTEPOCTIME.report
echo $WRITEFILE
dos2unix scratch.slurm
for i in $DATADIR/*.d ; do echo $i ; sed "s|$SEARCHTEXT|$i|g" scratch.slurm > $i.$WRITEFILE.tmp  ; sed "s|WRITEFILE|$WRITEFILE|g" $i.$WRITEFILE.tmp > $i.$WRITEFILE.slurm  ; sbatch $i.$WRITEFILE.slurm ; done
echo $WRITEFILE
ls -ltrh $DATADIR/*$WRITEFILE.slurm 
squeue -u ash022


#dos2unix slurmFP.sh
#bash slurmFP.sh $PWD/240827_Bead_test/dda
DATADIR=$1
CURRENTEPOCTIME=`date +%s`
WRITEDIR=slurmFP.$CURRENTEPOCTIME.results
SLURM=scratch.slurm
mkdir $WRITEDIR
#perl -pe 's/\r$//' < slurmFP.sh  > tmp
dos2unix $SLURM
#cp -rf $DATADIR/*.raw $WRITEDIR/.
for i in  $DATADIR/*.d; do echo $i; sed "s|RAWDATA|$i|" fp.manifest.txt > $i.$CURRENTEPOCTIME.manifest.txt ; sed "s|RAWDATA|$i.$CURRENTEPOCTIME|g" scratch.slurm > $i.$CURRENTEPOCTIME.slurm ; sbatch $i.$CURRENTEPOCTIME.slurm ; done


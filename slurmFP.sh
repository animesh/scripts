#dos2unix slurmFP.sh
#bash slurmFP.sh /nird/projects/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/Raw/ani
DATADIR=$1
CURRENTEPOCTIME=`date +%s`
SLURM=scratch.slurm
WRITEDIR=`basename $DATADIR`
mkdir $WRITEDIR
ls -ltrh $DATADIR/*.d/analysis.tdf_bin
rsync -Parv $DATADIR/*.d $WRITEDIR/ 
#cp -rf $DATADIR/*.d $WRITEDIR/.
ls -ltrh $DATADIR/*.d/analysis.tdf_bin > $WRITEDIR/files.txt
#perl -pe 's/\r$//' < slurmFP.sh  > tmp
dos2unix $SLURM
#cp -rf $DATADIR/*.raw $WRITEDIR/.
for i in  $PWD/$WRITEDIR/*.d; do echo $i; sed "s|RAWDATA|$i|" fp.manifest.txt > $i.$CURRENTEPOCTIME.manifest.txt ; sed "s|RAWDATA|$i.$CURRENTEPOCTIME|g" scratch.slurm > $i.$CURRENTEPOCTIME.slurm ; sbatch $i.$CURRENTEPOCTIME.slurm ; done


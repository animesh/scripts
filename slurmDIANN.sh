#cd /cluster/home/ash022/scripts
dos2unix scratch.slurm # slurmDIANN.sh
#bash slurmDIANN.sh /cluster/projects/nn9036k/scripts/0maike
#bash slurmDIANN.sh /cluster/projects/nn9036k/scripts/maike
#mkdir 0maike maike
#rsync -Parv /nird/projects/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2025/251024_Maike/*.d 0maike/
#rsync -Parv /nird/projects/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2025/251106_MAIKE_b/*.d maike/
#git checkout e2dad48e3f0337756b8adbeacd0f6968eb33c6e4 runDIANN.bat
#rsync -Parv /nird/projects/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/FastaDB/UP000005640_9606_unique_gene_MC2V3.predicted.predicted.speclib* /cluster/projects/nn9036k/FastaDB/
#for i in $PWD/maike/*.d ; do grep "TestFile.d" ; sed -i "s|TestFile\.d|$i|g" $i.slurm  ;done
DATADIR=$1
SEARCHTEXT=TestFile.d
CURRENTEPOCTIME=`date +%s`
WRITEFILE=$CURRENTEPOCTIME.report
echo $WRITEFILE
for i in $DATADIR/*.d ; do echo $i ; sed "s|$SEARCHTEXT|$i|g" scratch.slurm > $i.$WRITEFILE.tmp  ; sed "s|WRITEFILE|$WRITEFILE|g" $i.$WRITEFILE.tmp > $i.$WRITEFILE.slurm  ; sbatch $i.$WRITEFILE.slurm ; done
echo $WRITEFILE
ls -ltrh $DATADIR/*$WRITEFILE.slurm 
squeue -u ash022
#rsync -Parv maike/*.report.* /nird/projects/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2025/251106_MAIKE_b/
#rsync -Parv 0maike/*.report.* /nird/projects/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2025/251024_Maike/
#tar cvf Data/251106_MAIKE.SILAC.DIA.NN.tar TIMSTOF/LARS/2025/251106_MAIKE_b/*report.report.par*




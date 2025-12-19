#bash slurmDIANN.sh /cluster/projects/nn9036k/scripts/maike
#cd /cluster/home/ash022/scripts
dos2unix scratch.slurm # slurmDIANN.sh
#mkdir maike
#cp -rf ./DL/Raw/LARS/251212_Maike/251212_*H*P*d ./maike/.
#cp ./PD/FastaDB/UP000000589_10090.fasta ./maike/.
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




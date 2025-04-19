#dos2unix slurmDIANN.sh
#bash slurmDIANN.sh /cluster/projects/nn9036k/scripts/acet 
#squeue -u ash022
#wget https://github.com/vdemichev/DiaNN/releases/download/2.0/DIA-NN-2.1.0-Academia-Linux.zip
#unzip DIA-NN-2.1.0-Academia-Linux.zip
#cp -rf diann-2.1.0 /cluster/projects/nn9036k/
#cp /nird/projects/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/FastaDB/UP000005640_9606_unique_gene.fasta /cluster/projects/nn9036k/diann-2.1.0/
#cp /cluster/projects/nn9036k/diann-2.0/camprotR_240512_cRAP_20190401_full_tags.fasta /cluster/projects/nn9036k/diann-2.1.0/
#mkdir acet
#cp -rf /nird/projects/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2025/250411_HISTONE_SAHA/*DIA*.d acet/.
#cd /cluster/projects/nn9036k/diann-2.1.0/
#chmod +x diann.exe
DATADIR=$1
#leave following empty to include ALL files
SEARCHTEXT=TestFile.d
CURRENTEPOCTIME=`date +%s`
WRITEFILE=$CURRENTEPOCTIME.report
echo $WRITEFILE
dos2unix scratch.slurm
for i in $DATADIR/*.d ; do echo $i ; sed "s|$SEARCHTEXT|$i|g" scratch.slurm > $i.$WRITEFILE.slurm  ; sbatch $i.$WRITEFILE.slurm ; done
#mono $MAXQUANTCMD $k.xml ; cp -rf ./combined/txt $k.REP ; echo $k ; cd $LDIR 
echo $WRITEFILE
ls -ltrh $DATADIR/*$WRITEFILE.slurm 
squeue -u ash022

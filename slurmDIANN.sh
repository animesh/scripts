#bash slurmDIANN.sh /cluster/projects/nn9036k/scripts/kamilla 
#cd /cluster/home/ash022/scripts
#cp /nird/projects/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/FastaDB/UP000005640_9606_unique_gene.fasta /cluster/projects/nn9036k/diann-2.1.0/
#cp /cluster/projects/nn9036k/diann-2.0/camprotR_240512_cRAP_20190401_full_tags.fasta /cluster/projects/nn9036k/diann-2.1.0/
#cp /nird/projects/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/FastaDB/UP000005640_9606_unique_gene_C24_MC1_P735_MZ1001700_Mod3.predicted.speclib /cluster/projects/nn9036k/FastaDB/.
#mkdir kamilla
#cp -rf PD/TIMSTOF/LARS/2025/250428_Kamilla/*.d kamilla/.
#for i in kamilla/*.d*slurm ; do echo $i ; sed -i s/--threads\ 80/--threads\ 40/g $i;  done
#wget https://github.com/vdemichev/DiaNN/releases/download/2.0/DIA-NN-2.1.0-Academia-Linux.zip
#unzip DIA-NN-2.1.0-Academia-Linux.zip
#cp -rf diann-2.1.0 /cluster/projects/nn9036k/
#cd /cluster/projects/nn9036k/diann-2.1.0/
#chmod +x diann.exe
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

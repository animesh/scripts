#dos2unix scratch.slurm  slurmDIANN.sh
#mkdir tore tore_phos
#rsync -Parv  TIMSTOF/LARS/2026/260129_ToreBrembuPHOS/ToreB_8/260129_ToreBrembuPHOS_*.d tore_phos/
#rsync -Parv  TIMSTOF/LARS/2026/260107_Tore/Thalassiosira_pseudonana_PASA-proteins_uniprot.MC1V3.predicted.speclib tore/
#rsync -Parv  TIMSTOF/LARS/2026/260107_Tore/Thalassiosira_pseudonana_PASA-proteins_uniprot.fasta  tore/
#bash slurmDIANN.sh /cluster/projects/nn9036k/scripts/tore_phos
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
#rsync -Parv tore_phos/*.report.* /nird/projects/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2026/260129_ToreBrembuPHOS/ToreB_8/




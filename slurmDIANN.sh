#DIA-NN 1.9.2 (Data-Independent Acquisition by Neural Networks) update https://github.com/vdemichev/DiaNN/releases/tag/1.9.2
cd "C:\Program Files\DIA-NN\1.9.2"
#phoSTY
diann.exe --lib "" --threads 32 --verbose 1 --out "F:\promec\FastaDB\phoslibMC1V3mz100to1700c2to3humanreport.tsv" --qvalue 0.01 --matrices  --out-lib "F:\promec\FastaDB\phoslibMC1V3mz100to1700c2to3human.parquet" --gen-spec-lib --predictor --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "F:\promec\FastaDB\UP000005640_9606.fasta" --fasta-search --min-fr-mz 100 --max-fr-mz 1700 --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 100 --max-pr-mz 1700 --min-pr-charge 2 --max-pr-charge 3 --cut K*,R* --missed-cleavages 1 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --var-mod UniMod:21,79.966331,STY --peptidoforms --reanalyse --relaxed-prot-inf --rt-profiling
#https://github.com/vdemichev/DiaNN?tab=readme-ov-file#command-line-reference
diann.exe --f "F:\promec\TIMSTOF\LARS\2024\241002_zrimac\DIA\zr_IMAC_100ug_zoom20_1dia_25pepsep_S1-A2_1_8449.d" --f "F:\promec\TIMSTOF\LARS\2024\241002_zrimac\DIA\zr_IMAC_200ug_zoom20_1dia_25pepsep_S1-A5_1_8450.d" --f "F:\promec\TIMSTOF\LARS\2024\241002_zrimac\DIA\zr_IMAC_300ug_zoom20_1dia_25pepsep_S1-A8_1_8451.d" --f "F:\promec\TIMSTOF\LARS\2024\241002_zrimac\NEW\241009_Jurkat_zrImac_500dia_ny_Slot1-14_1_8588.d" --f "F:\promec\TIMSTOF\LARS\2024\241002_zrimac\NEW\241009_Jurkat_zrImac_500dia_lars_Slot1-14_1_8600.d" --f "F:\promec\TIMSTOF\LARS\2024\241002_zrimac\NEW\241009_Jurkat_zrImac_400dia_ny_Slot1-13_1_8586.d" --f "F:\promec\TIMSTOF\LARS\2024\241002_zrimac\NEW\241009_Jurkat_zrImac_400dia_lars_Slot1-13_1_8598.d" --f "F:\promec\TIMSTOF\LARS\2024\241002_zrimac\NEW\241009_Jurkat_zrImac_300dia_ny_Slot1-12_1_8584.d" --f "F:\promec\TIMSTOF\LARS\2024\241002_zrimac\NEW\241009_Jurkat_zrImac_300dia_lars_Slot1-12_1_8596.d" --f "F:\promec\TIMSTOF\LARS\2024\241002_zrimac\NEW\241009_Jurkat_zrImac_200dia_ny_Slot1-11_1_8582.d" --f "F:\promec\TIMSTOF\LARS\2024\241002_zrimac\NEW\241009_Jurkat_zrImac_200dia_lars_Slot1-11_1_8594.d" --f "F:\promec\TIMSTOF\LARS\2024\241002_zrimac\NEW\241009_Jurkat_zrImac_100dia_ny_Slot1-10_1_8580.d" --f "F:\promec\TIMSTOF\LARS\2024\241002_zrimac\NEW\241009_Jurkat_zrImac_100dia_lars_Slot1-10_1_8592.d" --lib "F:\promec\FastaDB\phoslibMC1V3mz100to1700c2to3human.predicted.speclib" --threads 64 --verbose 1 --out "F:\promec\TIMSTOF\LARS\2024\241002_zrimac\DIANN1p9p2\highprecisiondoublepassMBRnormlaizeReport.tsv" --qvalue 0.01 --matrices  --out-lib "F:\promec\TIMSTOF\LARS\2024\241002_zrimac\DIANN1p9p2\highprecisiondoublepassreport-lib.parquet" --gen-spec-lib --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "F:\promec\FastaDB\UP000005640_9606.fasta" --met-excision --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --var-mod UniMod:21,79.966331,STY --mass-acc 20.0 --mass-acc-ms1 20.0 --use-quant --double-search --individual-mass-acc --individual-windows --peptidoforms --reanalyse --relaxed-prot-inf --rt-profiling --global-norm
#git checkout 1b88b4332b7afe044820ee5eff575b13006fa04c mqparTTPdda.xml mqparTTPdia.xml scratch.slurm slurmMQrunTTP.sh
#dos2unix mqparTTPdda.xml scratch.slurm slurmMQrunTTP.sh
#rsync -Parv login.nird-lmd.sigma2.no:TIMSTOF/LARS/2024/240827_Bead_test .
#mkdir 240827_Bead_test/dia
#mv 240827_Bead_test/*DIA*d 240827_Bead_test/dia/
#mkdir 240827_Bead_test/dda
#mv 240827_Bead_test/*d 240827_Bead_test/dda/
#bash slurmMQrunTTP.sh /cluster/projects/nn9036k/MaxQuant_v2.6.3.0/bin/MaxQuantCmd.dll /cluster/projects/nn9036k/scripts/240827_Bead_test/dda /cluster/projects/nn9036k/FastaDB/uniprotkb_proteome_UP000005640_2024_07_22.fasta mqparTTPdda.xml scratch.slurm
#bash slurmMQrunTTP.sh /cluster/projects/nn9036k/MaxQuant_v2.6.3.0/bin/MaxQuantCmd.dll /cluster/projects/nn9036k/scripts/240827_Bead_test/dia /cluster/projects/nn9036k/FastaDB/uniprotkb_proteome_UP000005640_2024_07_22.fasta mqparTTPdia.xml scratch.slurm
#squeue -u ash022   | grep "240827_B" | wc
#18     144    1324	
#wget "https://datashare.biochem.mpg.de/s/qe1IqcKbz2j2Ruf/download?path=%2FDiscoveryLibraries&files=homo_sapiens.zip" -O HS.DIA.zip
#unzip HS.DIA.zip
#mv *.fasta FastaDB/.
#mv *.txt FastaDB/.
MAXQUANTCMD=$1
DATADIR=$2
FASTADIR=$3
PARAMFILE=$4
MQSLURMFILE=$5
CPU=10
thrMS=20
#leave following empty to include ALL files
PREFIXRAW=
SEARCHTEXT=TestFile.d
SEARCHTEXT2=SequencesFasta
SEARCHTEXT3=LocalCombinedFolder
SEARCHTEXT4=thrMS
LDIR=$PWD
CURRENTEPOCTIME=`date +%s`
WRITEDIR=$PARAMFILE.$CURRENTEPOCTIME.results
mkdir $WRITEDIR
#perl -pe 's/\r$//' < mqrun.sh  > tmp
dos2unix $PARAMFILE
for i in $DATADIR/*.d ; do echo $i ; 	j=$(basename $i) ; 	k=${j%%.*} ; mkdir $WRITEDIR/$k ; cp -r $i $WRITEDIR/$k ; sed "s|$SEARCHTEXT2|$FASTADIR|g" $LDIR/$PARAMFILE > $WRITEDIR/$k/$PARAMFILE.tmp1 ; sed "s|$SEARCHTEXT|$LDIR/$WRITEDIR/$k/$j|"  $WRITEDIR/$k/$PARAMFILE.tmp1 > $WRITEDIR/$k/$PARAMFILE.tmp2 ; sed "s|$SEARCHTEXT4|$thrMS|g"  $WRITEDIR/$k/$PARAMFILE.tmp2 > $WRITEDIR/$k/$PARAMFILE.tmp3 ; sed "s|$SEARCHTEXT3|$LDIR/$WRITEDIR/$k|"  $WRITEDIR/$k/$PARAMFILE.tmp3 > $WRITEDIR/$k/$k.xml ; rm $WRITEDIR/$k/$PARAMFILE.tmp*  ;done
#mono $MAXQUANTCMD $k.xml ; cp -rf ./combined/txt $k.REP ; echo $k ; cd $LDIR 
echo $WRITEDIR
#mv tmp  mqrun.sh
#mono $HOME/data/NORSTORE_OSL_DISK/NS9036K/promec/MaxQuant_1.6.8.0/MaxQuant/bin/MaxQuantCmd.exe -n $HOME/promec/Qexactive/Mirta/QExactive/Imen_Belhaj/RawData/out1678.xml
#-n for dryrun, -p <#checkpoint>
#date -d @1604251727
#find $WRITEDIR -name "proteinGroups.txt"  | xargs ls -ltrh
for i in $PWD/$WRITEDIR/*/*.xml
#dos2unix scratch.slurm 
#for i in $PWD/mqparTTP.phoSTY.xml.1663657305.results/*/*.xml 
    do echo $i
    j=$(basename $i)
    k=${j%%.*}
    d=$(dirname $i) 
    printf "$i\t$j\t$kt\t$d\n" | tee $d/$k.txt
    cat $d/$k.txt
    #cp MQSLURMFILE $d/$k.slurm 
    cp scratch.slurm $d/$k.slurm 
    sed "s|MQSLURMNAME|$k|" $d/$k.slurm  > slurm.tmp
    sed "s|MQSLURMLOG|$d/$k.txt|" slurm.tmp > slurm.tmp2
    sed "s|MQCMD|$MAXQUANTCMD|" slurm.tmp2 > slurm.tmp
    sed "s|MQWD|$d|" slurm.tmp > slurm.tmp2
    sed "s|MQPARF|$i|" slurm.tmp2 > $d/$k.slurm
    cat $d/$k.slurm
    sbatch $d/$k.slurm
done
tail -n 4 $WRITEDIR/*/*.slurm
ls $WRITEDIR/*/*.slurm | wc

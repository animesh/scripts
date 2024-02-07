#perl -pi -e's/\015\012/\012/g' slurmMQrun.sh
#perl -pi -e's/\015\012/\012/g' scratch.slurm
#perl -pi -e's/\015\012/\012/g' mqpar.xml
#bash slurmMQrun.sh /cluster/projects/nn9036k/MaxQuant_v2.1.4.0/bin/MaxQuantCmd.exe $PWD/MM /cluster/projects/nn9036k/FastaDB/sORFidAAleeGaoComb.unstar.fasta mqpar.K8R10.xml scratch.slurm
#perl -pi -e's/\015\012/\012/g' slurmMQrun.sh
#make sure mqrun.xml is in the directory where the script is and CHANGE following paths according to the MaxQuant Installation and representative parameter file for that version respectively CANNOT handle path containing spaces! create a symlink in such cases e.g. 
#for i in $HOME/PD/TIMSTOF/LARS/2021/November/*.d ; do echo $i; j=${i// /_}; echo $j; k=$(basename $j) ; echo $k; ln -s "$i" "$k"; done
#or make a local link without space for root directory
#ln -s /trd-project1/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2022/september/220908\ PHos/ phos
MAXQUANTCMD=$1
DATADIR=$2
FASTAFILE=$3
PARAMFILE=$4
MQSLURMFILE=$5
CPU=5
FDR=0.01
#leave following empty to include ALL files
PREFIXRAW=
SEARCHTEXT=TestFile.raw
SEARCHTEXT2=SequencesFasta
SEARCHTEXT3=LocalCombinedFolder
SEARCHTEXT4="Fdr>0.01"
LDIR=$PWD
CURRENTEPOCTIME=`date +%s`
WRITEDIR=$PARAMFILE.$CURRENTEPOCTIME.results
mkdir $WRITEDIR
for i in $DATADIR/*.raw ; do echo $i ; 	j=$(basename $i) ; 	k=${j%%.*} ; mkdir $WRITEDIR/$k ; cp $i $WRITEDIR/$k ; sed "s|$SEARCHTEXT2|$FASTAFILE|" $LDIR/$PARAMFILE > $WRITEDIR/$k/$PARAMFILE.tmp1 ; 	sed "s|$SEARCHTEXT|$LDIR/$WRITEDIR/$k/$j|"  $WRITEDIR/$k/$PARAMFILE.tmp1 > $WRITEDIR/$k/$PARAMFILE.tmp2 ; sed "s|$SEARCHTEXT4|Fdr>$FDR|"  $WRITEDIR/$k/$PARAMFILE.tmp2 > $WRITEDIR/$k/$PARAMFILE.tmp3 ; sed "s|$SEARCHTEXT3|$LDIR/$WRITEDIR/$k|"  $WRITEDIR/$k/$PARAMFILE.tmp3 > $WRITEDIR/$k/$k.xml ; rm $WRITEDIR/$k/$PARAMFILE.tmp*  ;done
#mono $MAXQUANTCMD $k.xml ; cp -rf ./combined/txt $k.REP ; echo $k ; cd $LDIR 
#find $WRITEDIR -name "*.xml" | parallel -j $CPU "mono $MAXQUANTCMD {}"
#perl -pe 's/\r$//' < mqrun.sh  > tmp
#mv tmp  mqrun.sh
#mono $HOME/data/NORSTORE_OSL_DISK/NS9036K/promec/MaxQuant_1.6.8.0/MaxQuant/bin/MaxQuantCmd.exe -n $HOME/promec/Qexactive/Mirta/QExactive/Imen_Belhaj/RawData/out1678.xml
#-n for dryrun, -p <#checkpoint>
#date -d @1604251727
echo $WRITEDIR
#find $WRITEDIR -name "proteinGroups.txt"  | xargs ls -ltrh

#mv tmp  mqrun.sh
#mono $HOME/data/NORSTORE_OSL_DISK/NS9036K/promec/MaxQuant_1.6.8.0/MaxQuant/bin/MaxQuantCmd.exe -n $HOME/promec/Qexactive/Mirta/QExactive/Imen_Belhaj/RawData/out1678.xml
#-n for dryrun, -p <#checkpoint>
#date -d @1604251727
#find $WRITEDIR -name "proteinGroups.txt"  | xargs ls -ltrh

for i in $PWD/$WRITEDIR/*/*.xml
#for i in $PWD/mqparTTP.phoSTY.xml.1663657305.results/*/*.xml 
    do echo $i
    j=$(basename $i)
    k=${j%%.*}
    d=$(dirname $i) 
    printf "$i\t$j\t$k\t$d\n" | tee $d/$k.txt
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
#ls -ltrh $WRITEDIR/*/*.txt
tail -f $WRITEDIR/*/*.txt
#for i in mqpar.K8R10.xml.1664621075.results/*/*.txt ; do s=$(stat --format=%s $i) ; if (($s>10000)); then j=$(basename $i) ; k=${j%%.*} ; d=$(dirname $i) ; ls -ltrh $d/$k.slurm; rm -rf $d/$k ; rm -rf $d/combined ; rm $d/$k.index ; sbatch $d/$k.slurm ; fi; done
#for i in mqpar.K8R10.xml.1664621075.results/*/*.slurm ; do echo $i ; sed 's/=36/=128/g' $i > $i.p11.slurm ; done
#for i in mqpar.K8R10.xml.1664621075.results/*/combined/txt/prot*.txt ; do s=$(stat --format=%s $i) ; if (($s>10000)); then j=$(basename $i) ; k=${j%%.*} 1188* 2022-11-01T18:38:16 
#for i in mqpar.K8R10.xml.1664621075.results/*/*.slurm ; do j=$(basename $i) ; k=${j%%.*} ; d=$(dirname $i) ; if test -f $d/combined/txt/prot*txt; then ls -ltrh $d/*.slurm ; fi; done  | wc
#for i in mqpar.K8R10.xml.1664621075.results/*/*.raw ; do j=$(basename $i) ; k=${j%%.*} ; d=$(dirname $i) ; s=$(stat --format=%s $d/combined/txt/prot*txt) ; if test -f $d/combined/txt/prot*txt; then ls $i ; fi; done
#tar cvzf prot.tgz  mqpar.K8R10.xml.1664621075.results/*/combined/txt/prot*txt
#ln -s /cluster/projects/nn9036k/MM/131030_SS+33983MM_run1.raw MMrerun/.
#bash slurmMQrun.sh /cluster/projects/nn9036k/MaxQuant_v2.1.4.0/bin/MaxQuantCmd.exe $PWD/P36729 /cluster/projects/nn9036k/FastaDB/sORFidAAleeGaoComb.unstar.fasta mqpar.K8R10.xml scratch.slurm
#tail -f mqpar.K8R10.xml.*/*/*.txt 
#for i in mqpar.K8R10.xml.1669563940.results/*/*.slurm ; do j=$(basename $i) ; k=${j%%.*} ; d=$(dirname $i) ; if [[ ! -f $d/combined/txt/proteinGroups.txt ]] ; then ls -ltrh $d/*.txt ; rm -rf $d/combined ; sbatch $i ; fi; done
#wget https://ftp.pride.ebi.ac.uk/pride/data/archive/2023/11/PXD039946/SampleAnnotation.xlsx
#Rscript parseXLS2list.r PXD039946/SampleAnnotation.xlsx > list
#awk '{print  "https://ftp.pride.ebi.ac.uk/pride/data/archive/2023/11/PXD039946/"$3}' list  | xargs wget
#dos2unix mqpar.xml scratch.slurm slurmMQrun.sh
#bash slurmMQrun.sh /cluster/projects/nn9036k/MaxQuant_2.4.3.0/bin/MaxQuantCmd.exe /cluster/work/users/ash022/ftp.pride.ebi.ac.uk/pride/data/archive/2023/11/PXD039946 /cluster/projects/nn9036k/FastaDB/uniprotkb_proteome_UP000000589_2024_01_18.fasta mqpar.xml scratch.slurm 

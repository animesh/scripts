#java -version openjdk version "17.0.3" 2022-04-19 OpenJDK Runtime Environment (build 17.0.3+7-Ubuntu-0ubuntu0.20.04.1) OpenJDK 64-Bit Server VM (build 17.0.3+7-Ubuntu-0ubuntu0.20.04.1, mixed mode, sharing)
#cd /mnt/promec-ns9036k/raw
#rm -rf  240321_NICOLA_*d
#cp -rf /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2024/240319_Nicola/240321_NICOLA_*d .
#ls -ltrh 240321_NICOLA_*
#cat man.2.txt 
#/mnt/promec-ns9036k/raw/240321_NICOLA_9_Slot2-9_1_6941.d        240321_NICOLA_9_Slot2-9_1_6941          DDA 
#$HOME/fragpipe/bin/fragpipe --headless --threads 20 --ram 80 --workflow $HOME/scripts/fp.workflow.txt --manifest man.2.txt  --workdir test.d.FPv20
#cp -rf /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/FastaDB/2024-06-01-decoys-contam-UP000005640.fas /home/ash022/fragpipe/2024-06-01-decoys-contam-UP000005640.fas
#$HOME/fragpipe/bin/fragpipe --headless --threads 20 --ram 80 --workflow $HOME/scripts/fp.workflow.txt --manifest man.2.txt  --workdir test.d.FPv20
#bash $HOME/scripts/fprunTTP.sh /mnt/promec-ns9036k/raw $HOME/scripts
for i in $1/240321_NICOLA_*.d ; do echo $i ; d=$(dirname $i) ; echo $d ; j=$(basename $i) ; echo $j ; cp -rf $i .; chmod -R 755 $j ; sed "s|RAWDIR|$PWD/$j|" $2/fp.manifest.txt > man.1.txt ; k=${j%%.*} ; echo $k ; sed "s|RAWFILE|$k|" man.1.txt > man.2.txt ; cat man.2.txt ;  $HOME/fragpipe/bin/fragpipe --headless --threads 20 --ram 80 --workflow $2/fp.workflow.txt --manifest man.2.txt  --workdir $j.FPv20 ;  ls -ltrh ${k}_uncalibrated.mzML ; k2=${k/\-/_} ; echo $k2; pep=$j.FPv20/$k2/$k.pepXML ; ls -ltrh  $pep; wc $j.FPv20/$k2/protein.tsv ; $HOME/.local/bin/AA_stat -n 20 --mzml ${k}_uncalibrated.mzML --pepxml $pep --dir $j.AA_stat_v2p5p6 ; echo $PWD   ; du -kh $j.AA_stat_v2p5p6 ; head $j.FPv20/ptm-shepherd-output/global.modsummary.tsv ; done
#head 240321_NICOLA_*.d.FPv20/ptm-shepherd-output/global.modsummary.tsv | awk '{print $1}' | sort | uniq -c
#tar cvzf 240321_NICOLA.FP.tgz  240321_NICOLA_*.d.FPv20
#ls -1 240321_NICOLA_*.d.AA_stat_v2p5p6 | awk '{print substr($1,1,5)}' | sort -r | uniq -c
#tar cvzf 240321_NICOLA.AA.tgz  240321_NICOLA_*.d.AA_stat_v2p5p6
#grep 240321_NICOLA_1_Slot2-1_1_6925.d disc/NS9036K/promec/*log
#for i in /nird/home/ash022/DL/TIMSTOF/LARS/240319_Nicola/240321_NICOLA_1_Slot2-1_1_6925.d ; do echo $i; tar -xvf  $HOME/disc/NS9036K/promec/backup.03_22_2024.tar.gz  "projects/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/Raw/LARS/240319_Nicola/"$(basename $i) --checkpoint=.1000000; done
#rm -rf TIMSTOF/LARS/2024/240319_Nicola/240321_NICOLA_*.d
#rm -rf TIMSTOF/LARS/2024/240319_Nicola/Raw
#rm -rf TIMSTOF/LARS/2024/240222_DIA/DIA_library/240222_Maike_DIAlib_*
#grep 240222_Maike_DIAlib_2_Slot2-4_1_6573.d disc/NS9036K/promec/*log
#tar -xvf  disc/NS9036K/promec/backup.02_24_2024.tar.gz  projects/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2024/240222_DIA/DIA_library/240222_Maike_DIAlib_2_Slot2-4_1_6573.d --checkpoint=.1000000
#tar -xvf  disc/NS9036K/promec/backup.06_07_2024.tar.gz  projects/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2024/240222_DIA/DIA_library/240222_Maike_DIAlib_2_Slot2-4_1_6573.d --checkpoint=.1000000
 

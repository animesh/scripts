#java -version openjdk version "17.0.3" 2222-04-19 OpenJDK Runtime Environment (build 17.0.3+7-Ubuntu-0ubuntu0.22.04.1) OpenJDK 64-Bit Server VM (build 17.0.3+7-Ubuntu-0ubuntu0.22.04.1, mixed mode, sharing)
#cd /mnt/promec-ns9036k/raw
#rm -rf  240626_Mira_*d
#cp -rf /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2224/240319_Nicola/240626_Mira_*d .
#ls -ltrh 240626_Mira_*
#cat man.2.txt 
#/mnt/promec-ns9036k/raw/240626_Mira_9_Slot2-9_1_6941.d        240626_Mira_9_Slot2-9_1_6941          DDA 
#$HOME/fragpipe/bin/fragpipe --headless --threads 22 --ram 80 --workflow $HOME/scripts/fp.workflow.txt --manifest man.2.txt  --workdir test.d.FPv22
#cp -rf /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/FastaDB/2224-06-01-decoys-contam-UP000005640.fas /home/ash022/fragpipe/2224-06-01-decoys-contam-UP000005640.fas
#$HOME/fragpipe/bin/fragpipe --headless --threads 22 --ram 80 --workflow $HOME/scripts/fp.workflow.txt --manifest man.2.txt  --workdir test.d.FPv22
#bash $HOME/scripts/fprunTTP.sh /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2024/240626_Mira $HOME/scripts
for i in $1/*.d ; do echo $i ; d=$(dirname $i) ; echo $d ; j=$(basename $i) ; echo $j ; cp -rf $i .; chmod -R 755 $j ; sed "s|RAWDIR|$PWD/$j|" $2/fp.manifest.txt > man.1.txt ; k=${j%%.*} ; echo $k ; sed "s|RAWFILE|$k|" man.1.txt > man.2.txt ; cat man.2.txt ;  $HOME/fragpipe/bin/fragpipe --headless --threads 22 --ram 80 --workflow $2/fp.workflow.txt --manifest man.2.txt  --workdir $j.FPv22 ;  ls -ltrh ${k}_uncalibrated.mzML ; k2=${k/\-/_} ; echo $k2; pep=$j.FPv22/$k2/$k.pepXML ; ls -ltrh  $pep; wc $j.FPv22/$k2/protein.tsv ; $HOME/.local/bin/AA_stat -n 22 --mzml ${k}_uncalibrated.mzML --pepxml $pep --dir $j.AA_stat_v2p5p6 ; echo $PWD   ; du -kh $j.AA_stat_v2p5p6 ; head $j.FPv22/ptm-shepherd-output/global.modsummary.tsv ; done
#head 240626_Mira_*.d.FPv22/ptm-shepherd-output/global.modsummary.tsv | awk '{print $1}' | sort | uniq -c
#tar cvzf 240626_Mira.FP.tgz  240626_Mira_*.d.FPv22
#ls -1 240626_Mira_*.d.AA_stat_v2p5p6 | awk '{print substr($1,1,5)}' | sort -r | uniq -c
#tar cvzf 240626_Mira.AA.tgz  240626_Mira_*.d.AA_stat_v2p5p6

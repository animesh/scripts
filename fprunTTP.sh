#java -version openjdk version "17.0.3" 2022-04-19 OpenJDK Runtime Environment (build 17.0.3+7-Ubuntu-0ubuntu0.20.04.1) OpenJDK 64-Bit Server VM (build 17.0.3+7-Ubuntu-0ubuntu0.20.04.1, mixed mode, sharing)
#cd /mnt/promec-ns9036k/raw
#cp F:\promec\TIMSTOF\LARS\2024\240319_Nicola\Raw\240321_NICOLA_16_Slot2-16_1_6955.d remove everything except 2024-03-23_13-17-16_One-column-separation 6955.m analysis.tdf analysis.tdf.bin chromatography-data.sqlite 
#bash $HOME/scripts/fprunTTP.sh /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2024/240319_Nicola $HOME/scripts
for i in $1/*.d ; do echo $i ; d=$(dirname $i) ; echo $d ; j=$(basename $i) ; echo $j ; cp -rf $i .; chmod -R 755 $j ; sed "s|RAWDIR|$PWD/$j|" $2/fp.manifest.txt > man.1.txt ; k=${j%%.*} ; echo $k ; sed "s|RAWFILE|$k|" man.1.txt > man.2.txt ; cat man.2.txt ;  $HOME/fragpipe/bin/fragpipe --headless --threads 20 --ram 80 --workflow $2/fp.workflow.txt --manifest man.2.txt  --workdir $j.FPv20 ;  ls -ltrh ${k}_uncalibrated.mzML ; k2=${k/\-/_} ; echo $k2; pep=$j.FPv20/$k2/$k.pepXML ; ls -ltrh  $pep; wc $j.FPv20/$k2/protein.tsv ; $HOME/.local/bin/AA_stat -n 20 --mzml ${k}_uncalibrated.mzML --pepxml $pep --dir $j.AA_stat_v2p5p6 ; echo $PWD   ; du -kh $j.AA_stat_v2p5p6 ; head $j.FPv20/ptm-shepherd-output/global.modsummary.tsv ; done
#head $HOME/scripts/fp.workflow.txt
#cp -rf /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/FastaDB/2023-11-11-decoys-reviewed-contam-UP000005640.fas /home/ash022/fragpipe/2023-11-11-decoys-reviewed-contam-UP000005640.fas
#cat man.2.txt 
#/mnt/promec-ns9036k/raw/240105_blank_Slot1-53_1_6209.d  240105_blank_Slot1-53_1_6209               DDA 
#$HOME/fragpipe/bin/fragpipe --headless --threads 20 --ram 80 --workflow $HOME/scripts/fp.workflow.txt --manifest man.2.txt  --workdir test.d.FPv20
#head *.FPv20/ptm-shepherd-output/global.modsummary.tsv | awk '{print $1}' | sort | uniq -c
#ls -1 *.d.AA_stat_v2p5p6 | awk '{print substr($1,1,5)}' | sort -r | uniq -c
#tar cvzf 240109_lymphSILAC.AA.tgz  240105_*.d.AA_stat_v2p5p6
#tar cvzf 240109_lymphSILAC.FP.tgz  240105_*.d.FP*
#tar cvzf 240103_KSH.tgz  240103_KSH*.d.AA_stat_v2p5p6
#rsync -Parv ash022@login.nird-lmd.sigma2.no:NS9036K/raw/240103_KSH.tgz .
#cd /cygdrive/f/promec/TIMSTOF/LARS/2024/240109_lymphSILAC
#rsync -Parv ash022@login.nird-lmd.sigma2.no:NS9036K/raw/240109*tgz .
#tar xvf 240109_lymphSILAC.FP.tgz
#tar xvf 240109_lymphSILAC.AA.tgz
#head 240522_Tom_Kelt*.d.FP*.FPv20/ptm-shepherd-output/global.modsummary.tsv | awk '{print $1}' | sort | uniq -c
#head 240605_Veronica*FP*/ptm-shepherd-output/global.modsummary.tsv | awk '{print $1}' | sort | uniq -c
#bash $HOME/scripts/fprunTTP.sh /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/Raw/LARS/240624_Kasif $HOME/scripts
#ls -ltrh
#bash $HOME/scripts/fprunTTP.sh /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2024/240624_Kasif $HOME/scripts
#head 240605_Veronica*FP*/ptm-shepherd-output/global.modsummary.tsv | awk '{print $1}' | sort | uniq -c
#head 240605_Veronica*FP*/ptm-shepherd-output/global.modsummary.tsv | awk '{print $1}' | sort | uniq -c
#head 240*K*FP*/ptm-shepherd-output/global.modsummary.tsv | awk '{print $1}' | sort | uniq -c

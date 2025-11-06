#cd /mnt/promec-ns9036k/raw
#bash $HOME/scripts/fprunTTP.sh /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2025/250214_HISTONE $HOME/scripts
#grep "Histone H"  250213_H1_DDA_Slot1-19_1_9546.d.FPv22macetprop/250213_H1_DDA_Slot1_19_1_9546/protein.tsv  | wc
#     18     505    8754
#wc  250213_H1_DDA_Slot1-19_1_9546.d.FPv22macetprop/250213_H1_DDA_Slot1_19_1_9546/protein.tsv
#   618  18793 195884 250213_H1_DDA_Slot1-19_1_9546.d.FPv22macetprop/250213_H1_DDA_Slot1_19_1_9546/protein.tsv
#wc  250213_H1_DDA_Slot1-19_1_9546.d.FPv22macetprop/combined_site_*
#   926   7414  78391 250213_H1_DDA_Slot1-19_1_9546.d.FPv22macetprop/combined_site_K_112.0524.tsv
#    25    205   2237 250213_H1_DDA_Slot1-19_1_9546.d.FPv22macetprop/combined_site_K_14.0157.tsv
#     9     76    836 250213_H1_DDA_Slot1-19_1_9546.d.FPv22macetprop/combined_site_K_28.0313.tsv
#    43    350   3864 250213_H1_DDA_Slot1-19_1_9546.d.FPv22macetprop/combined_site_K_42.0106.tsv
#   336   2694  30513 250213_H1_DDA_Slot1-19_1_9546.d.FPv22macetprop/combined_site_K_56.0622.tsv
#   265   2125  23629 250213_H1_DDA_Slot1-19_1_9546.d.FPv22macetprop/combined_site_M_15.9949.tsv
#  1604  12864 139470 total
  
#cp -rf 250213_*.d.*macetprop*  /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2025/250213_HistonePTM/.
#animeshs@dmed6942:~/promec/promec$ rsync -Parv --min-size=1  --exclude=.gd --exclude=.tmp.driveupload  ash022@login1.nird-lmd.sigma2.no:PD/TIMSTOF/LARS/2025/250213_HistonePTM/ TIMSTOF/LARS/2025/250213_HistonePTM/   

#git checkout fa54e2fa0a932cbdb29be54f2bdf242d66d939ab fprunTTP.sh
#perl -p -i -e "s/\r/\n/g" fprunTTP.sh 
#java -version openjdk version "17.0.3" 2222-04-19 OpenJDK Runtime Environment (build 17.0.3+7-Ubuntu-0ubuntu0.22.04.1) OpenJDK 64-Bit Server VM (build 17.0.3+7-Ubuntu-0ubuntu0.22.04.1, mixed mode, sharing)
#cp -rf /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2224/240319_Nicola/240626_Mira_*d .
#ls -ltrh 240626_Mira_*
#cat man.2.txt 
#/mnt/promec-ns9036k/raw/240626_Mira_9_Slot2-9_1_6941.d        240626_Mira_9_Slot2-9_1_6941          DDA 
#cp -rf /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/FastaDB/2224-06-01-decoys-contam-UP000005640.fas /home/ash022/fragpipe/2224-06-01-decoys-contam-UP000005640.fas
#$HOME/fragpipe/bin/fragpipe --headless --threads 22 --ram 80 --workflow $HOME/scripts/fp.workflow.txt --manifest man.2.txt  --workdir test.d.FPv22macetprop


#$HOME/fragpipe/bin/fragpipe --headless --threads 22 --ram 80 --workflow $HOME/scripts/fp.workflow.txt --manifest man.2.txt  --workdir test.d.FPv22macetprop

for i in $1/*.d ; do echo $i ; d=$(dirname $i) ; echo $d ; j=$(basename $i) ; echo $j ; cp -rf $i .; chmod -R 755 $j ; sed "s|RAWDIR|$PWD/$j|" $2/fp.manifest.txt > man.1.txt ; k=${j%%.*} ; echo $k ; sed "s|RAWFILE|$k|" man.1.txt > man.2.txt ; cat man.2.txt ;  $HOME/fragpipe/bin/fragpipe --headless --threads 22 --ram 80 --workflow $2/fp.dl.workflow.txt --manifest man.2.txt  --workdir $j.FPv22macetprop ;  ls -ltrh ${k}_calibrated.mzML ; k2=${k/\-/_} ; echo $k2; pep=$j.FPv22macetprop/$k2/$k.pepXML ; ls -ltrh  $pep; wc $j.FPv22macetprop/$k2/protein.tsv ; $HOME/.local/bin/AA_stat -n 22 --mzml ${k}_calibrated.mzML --pepxml $pep --dir $j.AA_stat_v2p5p6macetprop ; echo $PWD   ; du -kh $j.AA_stat_v2p5p6macetprop ; head $j.FPv22macetprop/ptm-shepherd-output/global.modsummary.tsv ; done

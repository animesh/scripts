#cd /mnt/promec-ns9036k/raw
#bash $HOME/scripts/fprunTTP.sh /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2025/250214_HISTONE $HOME/scripts
#grep "Histone H"  250213_H1_DDA_Slot1-19_1_9546.d.FPv22/250213_H1_DDA_Slot1_19_1_9546/protein.tsv  | wc
#     17     607    6924
#wc  250213_H1_DDA_Slot1-19_1_9546.d.FPv22/250213_H1_DDA_Slot1_19_1_9546/protein.tsv
# 635  20113 177251 250213_H1_DDA_Slot1-19_1_9546.d.FPv22/250213_H1_DDA_Slot1_19_1_9546/protein.tsv
#cat  250213_H1_DDA_Slot1-19_1_9546.d.FPv22/ptm-shepherd-output/global.modsummary.tsv 
#Modification    Mass Shift      250213_H1_DDA_Slot1_19_1_9546_PSMs      250213_H1_DDA_Slot1_19_1_9546_percent_PSMs
#Propionate labeling reagent light form (N-term & K)/Acrolein addition +56       56.026215       2987    52.0200
#Acrolein addition +112  112.05243       1190    20.7240
#None    0.0     399     6.9490
#Unannotated mass-shift 55.0356  55.0356 100     1.7420
#Unannotated mass-shift -44.0518 -44.0518        53      0.9230
#Unannotated mass-shift 56.0008  56.0008 25      0.4350
#Pyro-glu from Q/Loss of ammonia -17.026549      24      0.4180
#carboxyethyl/Dihydroxy methylglyoxal adduct/Ethoxyformylation   72.021129       24      0.4180
#Propionaldehyde +40     40.0313 22      0.3830
#Unannotated mass-shift 56.0522  56.0522 17      0.2960
#Unannotated mass-shift 84.0582  84.0582 16      0.2790
#Unannotated mass-shift 240.1524 240.1524        15      0.2610
#Unannotated mass-shift -100.0718        -100.0718       11      0.1920
#Unannotated mass-shift 240.1414 240.1414        11      0.1920
#Unannotated mass-shift 126.0734 126.0734        10      0.1740
#Unannotated mass-shift 72.0108  72.0108 10      0.1740
#Iodoacetamide derivative/Addition of Glycine/Addition of G      57.021464       10      0.1740

#tar cvzf 250213_H.tgz 250213_*.d.* 
#cp -rf 250213_H.tgz /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2025/250213_HistonePTM/.

#cp -rf 250213_H.tgz 250213_*.d.*  /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2025/250213_HistonePTM/.

#animeshs@dmed6942:~/promec/promec$ rsync -Parv --min-size=1  --exclude=.gd --exclude=.tmp.driveupload  ash022@login1.nird-lmd.sigma2.no:PD/TIMSTOF/LARS/2025/250213_HistonePTM/ TIMSTOF/LARS/2025/250213_HistonePTM/   

#git checkout fa54e2fa0a932cbdb29be54f2bdf242d66d939ab fprunTTP.sh
#perl -p -i -e "s/\r/\n/g" fprunTTP.sh 
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

for i in $1/*.d ; do echo $i ; d=$(dirname $i) ; echo $d ; j=$(basename $i) ; echo $j ; cp -rf $i .; chmod -R 755 $j ; sed "s|RAWDIR|$PWD/$j|" $2/fp.manifest.txt > man.1.txt ; k=${j%%.*} ; echo $k ; sed "s|RAWFILE|$k|" man.1.txt > man.2.txt ; cat man.2.txt ;  $HOME/fragpipe/bin/fragpipe --headless --threads 22 --ram 80 --workflow $2/fp.workflow.txt --manifest man.2.txt  --workdir $j.FPv22 ;  ls -ltrh ${k}_uncalibrated.mzML ; k2=${k/\-/_} ; echo $k2; pep=$j.FPv22/$k2/$k.pepXML ; ls -ltrh  $pep; wc $j.FPv22/$k2/protein.tsv ; $HOME/.local/bin/AA_stat -n 22 --mzml ${k}_uncalibrated.mzML --pepxml $pep --dir $j.AA_stat_v2p5p6 ; echo $PWD   ; du -kh $j.AA_stat_v2p5p6 ; head $j.FPv22/ptm-shepherd-output/global.modsummary.tsv ; done

#head 240626_Mira_*.d.FPv22/ptm-shepherd-output/global.modsummary.tsv | awk '{print $1}' | sort | uniq -c

#tar cvzf 240626_Mira.FP.tgz  240626_Mira_*.d.FPv22

#ls -1 240626_Mira_*.d.AA_stat_v2p5p6 | awk '{print substr($1,1,5)}' | sort -r | uniq -c

#tar cvzf 240626_Mira.AA.tgz  240626_Mira_*.d.AA_stat_v2p5p6








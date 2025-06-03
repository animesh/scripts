#perl -p -i -e 's/\r\n/\n/g' $HOME/scripts/fprunTTP.sh 
#cp /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/FastaDB/2025-06-02-decoys-contam-UP000002494_10116.fasta.* /mnt/promec-ns9036k/FPv22lin/fragpipe/.
#grep "^>" /mnt/promec-ns9036k/FPv22lin/fragpipe/2025-06-02-decoys-contam-UP000002494_10116.fasta.fas | wc
#  45042  492864 4910226
#cd /mnt/promec-ns9036k/raw
#bash $HOME/scripts/fprunTTP.sh /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2025/250520_Cecilie/Raw $HOME/scripts
#grep "Histone H"  250520_200ngHelaQC_DDA_D_Slot1-54_1_10418.d.FPv22macetprop/*/protein.tsv  | wc
#      15     461    4042
#wc 250520_200ngHelaQC_DDA_D_Slot1-54_1_10418.d.FPv22macetprop/*/protein.tsv  
#  3608 107235 821195 250520_200ngHelaQC_DDA_D_Slot1-54_1_10418.d.FPv22macetprop/250520_200ngHelaQC_DDA_D_Slot1_54_1_10418/protein.tsv
#cp -rf 250520_*.d.*macetprop*  /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2025/250520_Cecilie/Raw/.
#animeshs@dmed6942:~/promec/promec$ rsync -Parv --min-size=1  --exclude=.gd --exclude=.tmp.driveupload  ash022@login1.nird-lmd.sigma2.no:PD/TIMSTOF/LARS/2025/250520_Cecilie/Raw/   
#java -version openjdk version "17.0.3" 2222-04-19 OpenJDK Runtime Environment (build 17.0.3+7-Ubuntu-0ubuntu0.22.04.1) OpenJDK 64-Bit Server VM (build 17.0.3+7-Ubuntu-0ubuntu0.22.04.1, mixed mode, sharing)
#$HOME/fragpipe/bin/fragpipe --headless --threads 22 --ram 80 --workflow $HOME/scripts/fp.workflow.txt --manifest man.2.txt  --workdir test.d.FPv22macetprop
#$HOME/fragpipe/bin/fragpipe --headless --threads 22 --ram 80 --workflow $HOME/scripts/fp.workflow.txt --manifest man.2.txt  --workdir test.d.FPv22macetprop
for i in $1/*.d ; do echo $i ; d=$(dirname $i) ; echo $d ; j=$(basename $i) ; echo $j ; cp -rf $i .; chmod -R 755 $j ; sed "s|RAWDIR|$PWD/$j|" $2/fp.manifest.txt > man.1.txt ; k=${j%%.*} ; echo $k ; sed "s|RAWFILE|$k|" man.1.txt > man.2.txt ; cat man.2.txt ;  $HOME/fragpipe/bin/fragpipe --headless --threads 22 --ram 80 --workflow $2/fp.workflow.txt --manifest man.2.txt  --workdir $j.FPv22macetprop ;  ls -ltrh ${k}_calibrated.mzML ; k2=${k/\-/_} ; echo $k2; pep=$j.FPv22macetprop/$k2/$k.pepXML ; ls -ltrh  $pep; wc $j.FPv22macetprop/$k2/protein.tsv ; $HOME/.local/bin/AA_stat -n 22 --mzml ${k}_calibrated.mzML --pepxml $pep --dir $j.AA_stat_v2p5p6macetprop ; echo $PWD   ; du -kh $j.AA_stat_v2p5p6macetprop ; head $j.FPv22macetprop/ptm-shepherd-output/global.modsummary.tsv ; done
#head 250520_*.FPv22macetprop/ptm-shepherd-output/global.modsummary.tsv
#ls  250520_*.AA_stat_v2p5p6macetprop 
#cd /mnt/promec-ns9036k/raw
#ash022@deep-learn-1746533977-deep-learning-tools:/mnt/promec-ns9036k/raw$ bash $HOME/scripts/fprunTTP.dl.sh /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2025/251103_STEVEN $HOME/scripts
#git checkout fa54e2fa0a932cbdb29be54f2bdf242d66d939ab fprunTTP.sh
#perl -p -i -e "s/\r/\n/g" fprunTTP.sh 
#java -version openjdk version "17.0.3" 2222-04-19 OpenJDK Runtime Environment (build 17.0.3+7-Ubuntu-0ubuntu0.22.04.1) OpenJDK 64-Bit Server VM (build 17.0.3+7-Ubuntu-0ubuntu0.22.04.1, mixed mode, sharing)
#cp -rf /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2224/240319_Nicola/240626_Mira_*d .
#ls -ltrh 240626_Mira_*
#cat man.2.txt 
#/mnt/promec-ns9036k/raw/240626_Mira_9_Slot2-9_1_6941.d        240626_Mira_9_Slot2-9_1_6941          DDA 
#cp -rf /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/FastaDB/2025-11-06-decoys-contam-uniprotkb_proteome_UP000006548_2025_11_06.fasta.fas /mnt/promec-ns9036k/FPv22lin/.
#grep "^>" /mnt/promec-ns9036k/FPv22lin/fragpipe/2025-11-06-decoys-contam-uniprotkb_proteome_UP000006548_2025_11_06.fasta.fas | wc
#  83430  899782 9620342
#$HOME/fragpipe/bin/fragpipe --headless --threads 22 --ram 80 --workflow $HOME/scripts/fp.workflow.txt --manifest man.2.txt  --workdir test.d.FPv22
#grep "^>" /mnt/promec-ns9036k/FPv22lin/fragpipe/2025-11-06-decoys-contam-uniprotkb_proteome_UP000006548_2025_11_06.fasta.fas | wc
#  83430  899782 9620342
for i in $1/*.d ; do echo $i ; d=$(dirname $i) ; echo $d ; j=$(basename $i) ; echo $j ; cp -rf $i .; chmod -R 755 $j ; sed "s|RAWDIR|$PWD/$j|" $2/fp.manifest.txt > man.1.txt ; k=${j%%.*} ; echo $k ; sed "s|RAWFILE|$k|" man.1.txt > man.2.txt ; cat man.2.txt ;  $HOME/fragpipe/bin/fragpipe --headless --threads 22 --ram 80 --workflow $2/fp.dl.workflow.txt --manifest man.2.txt  --workdir $j.FPv22 ;  ls -ltrh ${k}_calibrated.mzML ; k2=${k/\-/_} ; echo $k2; pep=$j.FPv22/$k2/$k.pepXML ; ls -ltrh  $pep; wc $j.FPv22/$k2/protein.tsv ; $HOME/.local/bin/AA_stat -n 22 --mzml ${k}_calibrated.mzML --pepxml $pep --dir $j.AA_stat_v2p5p6 ; echo $PWD   ; du -kh $j.AA_stat_v2p5p6 ; head $j.FPv22/ptm-shepherd-output/global.modsummary.tsv ; done

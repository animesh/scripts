#java -version openjdk version "17.0.3" 2222-04-19 OpenJDK Runtime Environment (build 17.0.3+7-Ubuntu-0ubuntu0.22.04.1) OpenJDK 64-Bit Server VM (build 17.0.3+7-Ubuntu-0ubuntu0.22.04.1, mixed mode, sharing)
#wget https://objects.githubusercontent.com/github-production-release-asset-2e65be/91836776/663a6fea-f259-41a3-b144-18c8d8954127?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=releaseassetproduction%2F20240924%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20240924T075300Z&X-Amz-Expires=300&X-Amz-Signature=ec5f2edae30b98766ee13a9d2fd1829ad35cfda349da48032923b95bd0d14d3d&X-Amz-SignedHeaders=host&response-content-disposition=attachment%3B%20filename%3DFragPipe-22.0.zip&response-content-type=application%2Foctet-stream
#mamba create -n mono
#mamba install mono
#mamba init
#bash
#mamba activate mono
#cd /mnt/promec-ns9036k/raw
#rm -rf 240917_Dongjie*
#bash $HOME/scripts/fprunTTP.sh /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/USERS/Dongjie/20240917_Dongjie_PseudoU/QEHF $HOME/scripts
#cp -rf /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2224/240319_Nicola/240626_Mira_*d .
#ls -ltrh 240626_Mira_*
#cat man.2.txt 
#/mnt/promec-ns9036k/raw/240917_Dongjie_3U-3.raw 240917_Dongjie_3U_3             DDA         
#cp -rf /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/FastaDB/2224-06-01-decoys-contam-UP000005640.fas /home/ash022/fragpipe/2224-06-01-decoys-contam-UP000005640.fas
#$HOME/fragpipe/bin/fragpipe --headless --threads 22 --ram 80 --workflow $HOME/scripts/fp.workflow.txt --manifest man.2.txt  --workdir test.raw.FPv22
for i in $1/*.raw ; do echo $i ; d=$(dirname $i) ; echo $d ; j=$(basename $i) ; echo $j ; cp -rf $i .; chmod -R 755 $j ; sed "s|RAWDIR|$PWD/$j|" $2/fp.manifest.txt > man.1.txt ; k=${j%%.*} ; echo $k ; k2=${k/\-/_} ; echo $k2; sed "s|RAWFILE|$k2|" man.1.txt > man.2.txt ; cat man.2.txt ;  $HOME/fragpipe/bin/fragpipe --headless --threads 22 --ram 80 --workflow $2/fp.workflow.txt --manifest man.2.txt  --workdir $j.FPv22 ;  ls -ltrh ${k}_uncalibrated.mzML ; pep=$j.FPv22/$k2/$k.pepXML ; ls -ltrh  $pep; wc $j.FPv22/$k2/protein.tsv ; $HOME/.local/bin/AA_stat -n 22 --mzml ${k}_uncalibrated.mzML --pepxml $pep --dir $j.AA_stat_v2p5p6 ; echo $PWD   ; du -kh $j.AA_stat_v2p5p6 ; head $j.FPv22/ptm-shepherd-output/global.modsummary.tsv ; done

#head 240917_Dongjie*.raw.FPv22/ptm-shepherd-output/global.modsummary.tsv | awk '{print $1}' | sort | uniq -c
#tar cvzf 240917_Dongjie.FP.tgz  240917_Dongjie*.raw.FPv22
#ls -1 240917_Dongjie*.d.AA_stat_v2p5p6 | awk '{print substr($1,1,5)}' | sort -r | uniq -c
#tar cvzf 240917_Dongjie.AA.tgz  240917_Dongjie*.raw.AA_stat_v2p5p6

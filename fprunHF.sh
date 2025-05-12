#git checkout 765cd0b3e385a4c0e4aa0656f9db4249ec47cbaf fp.workflow.txt 
#cd /mnt/promec-ns9036k/raw
#perl -p -i -e 's/\r\n/\n/g' $HOME/scripts/fprunHF.sh $HOME/scripts/fp.workflow.txt  OR try
#perl -e"BEGIN{ binmode STDOUT }" -pe1 $HOME/scripts/fp.workflow.txt > fp.workflow.txt
#perl -e"BEGIN{ binmode STDOUT }" -pe1 $HOME/scripts/fprunHF.sh > fprunHF.sh
#cp fp* $HOME/scripts/
#bash
#mamba activate mono
#bash $HOME/scripts/fprunHF.sh /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/HF/Lars/2025/250511_edanSilac $HOME/scripts
#bash $HOME/scripts/fprunHF.sh /mnt/promec-ns9036k/NORSTORE_OSL_DISK/NS9036K/promec/promec/HF/Lars/2025/250312_EDAN $HOME/scripts
for i in $1/*.raw ; do echo $i ; d=$(dirname $i) ; echo $d ; j=$(basename $i) ; echo $j ; cp -rf $i .; chmod -R 755 $j ; sed "s|RAWDIR|$PWD/$j|" $2/fp.manifest.txt > man.1.txt ; k=${j%%.*} ; echo $k ; k2=${k/\-/_} ; echo $k2; sed "s|RAWFILE|$k2|" man.1.txt > man.2.txt ; cat man.2.txt ;  $HOME/fragpipe/bin/fragpipe --headless --threads 22 --ram 80 --workflow $2/fp.workflow.txt --manifest man.2.txt  --workdir $j.FPv22 ;  ls -ltrh ${k}_uncalibrated.mzML ; pep=$j.FPv22/$k2/$k.pepXML ; ls -ltrh  $pep; wc $j.FPv22/$k2/protein.tsv ; $HOME/.local/bin/AA_stat -n 22 --mzml ${k}_uncalibrated.mzML --pepxml $pep --dir $j.AA_stat_v2p5p6 ; echo $PWD   ; du -kh $j.AA_stat_v2p5p6 ; head $j.FPv22/ptm-shepherd-output/global.modsummary.tsv ; done
#tar cvzf 250509_EDAN.FP.tgz  250509_EDAN*.raw.FPv22
#tar cvzf 250509_EDAN.AA.tgz  250509_EDAN*.raw.AA_stat_v2p5p6
#head 250509_EDAN*.raw.FPv22/ptm-shepherd-output/global.modsummary.tsv | awk '{print $1}' | sort | uniq -c
#ls -1 250509_EDAN*AA_stat_v2p5p6 | awk '{print substr($1,1,8)}' | sort -r | uniq -c


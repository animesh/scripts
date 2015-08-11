#!/bin/bash 
# 
# wav2mp3
# 
for i in *.wav; do
    #out=$(ls $i | sed -e 's/.wav//g')
    #out=$(echo $i | sed -e 's/.wav$//')
    #lame -h -b 192 "$i" "$out.mp3"
    lame -h -b 192 "$i" "${i%.wav}.mp3"
done

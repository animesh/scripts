for i in *.[Mm][Pp]3; do mv "$i" `echo $i | tr '[A-Z]' '[a-z]'`; done
for i in *.[Ww][Mm][Aa]; do mv "$i" `echo $i | tr '[A-Z]' '[a-z]'`; done
for i in *.mp3; do mv "$i" `echo $i | tr ' ' '_'`; done
for i in *.wma; do mv "$i" `echo $i | tr ' ' '_'`; done
for i in *.mp3; do mplayer $i -ao pcm:file=`basename $i .mp3`.wav; done
for i in *.wma; do mplayer $i -ao pcm:file=`basename $i .wma`.wav; done
#cdr1.pl
#sudo burncd -f 'o/p from cdr2.pl' fixate

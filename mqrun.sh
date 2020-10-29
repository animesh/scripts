#USAGE: bash mqrun.sh
#make sure mqrun.xml is in the directory where the script is!
#-n for dryrun, -p <#checkpoint>
#mono mono /mnt/c/Users/animeshs/MaxQuant_1.6.17.0.zip/MaxQuant/bin/MaxQuantCmd.exe 200925_SINTEF_sample-T2-M3_positionA8.xml
#change the following paths according to the MaxQuant Installation, directory containing experiment raw files, fasta file and representative parameter file for that version respectively
MAXQUANTCMD=/mnt/c/Users/animeshs/MaxQuant_1.6.17.0.zip/MaxQuant/bin/MaxQuantCmd.exe
DATADIR=/mnt/f/SINTEF/mqrun
FASTAFILE=/mnt/f/SINTEF/mqrun/AP-004_translations.fa
PARAMFILE=mqpar.xml
#leave following empty to include ALL files
PREFIXRAW=
SEARCHTEXT=TestFile.raw
SEARCHTEXT2=SequencesFasta
LDIR=$PWD
for i in $DATADIR/*.raw
	do cd $DATADIR
	echo $i
	j=$(basename $i)
	k=${j%%.*}
	sed "s|$SEARCHTEXT2|$FASTAFILE|" $LDIR/$PARAMFILE > tmp
	sed "s|$SEARCHTEXT|$DATADIR/$j|"  tmp > $k.xml
	mono $MAXQUANTCMD $k.xml
	cp -rf ./combined/txt $k.REP
	echo $k
	cd $LDIR
done

: '
https://gist.github.com/elrubio/4e7797d7d0d9add96ce82f0472f17908
https://askubuntu.com/questions/76808/how-do-i-use-variables-in-a-sed-command
update at sharma.animesh@gmail.com :)
'

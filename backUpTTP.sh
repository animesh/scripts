# make sure to remove space in provided dir by creating a symlink?
# ln -s TIMSTOF/LARS/2022/june/220613\ Kristine/ 220613_Kristine 
# export KEYMINIO=<get the key from minioserver server-drive.promec.sigma2.no user promecshare>
CURRENTEPOCTIME=`date +%s`
DATAPATH=$1
WRITEDIR=$HOME/Data
DIRNAME=$(basename $DATAPATH) 
FILENAME=$DIRNAME.$CURRENTEPOCTIME.tar
ls $DATAPATH/*.d 
ls $DATAPATH/combined/txt/*.txt
tar cvf $WRITEDIR/$FILENAME $DATAPATH/*.d $DATAPATH/combined/txt/*.txt
echo data- $DATAPATH to- $WRITEDIR dir- $DIRNAME file- $FILENAME 
md5sum $WRITEDIR/$FILENAME > $WRITEDIR/$FILENAME.MD5 
cat $WRITEDIR/$FILENAME.MD5
module load Python/3.11.5-GCCcore-13.2.0
python3 scripts/shareLink.py $KEYMINIO Data $FILENAME
# bash scripts/backUpTTP.sh 220613_Kristine


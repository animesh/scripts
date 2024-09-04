# make sure to remove space in provided dir by creating a symlink?
# ln -s PD/Elite/LARS/2019/august/190820\ Camilla\ wolo 190820_Camilla_wolo
# export KEYMINIO=<get the key from minioserver server-drive.promec.sigma2.no user promecshare>
CURRENTEPOCTIME=`date +%s`
DATAPATH=$1
WRITEDIR=$HOME/Data
DIRNAME=$(basename $DATAPATH) 
FILENAME=$DIRNAME.$CURRENTEPOCTIME.tar
ls $DATAPATH/*.raw 
ls $DATAPATH/combined/txt/*.txt
tar cvf $WRITEDIR/$FILENAME $DATAPATH/*.raw $DATAPATH/combined/txt/*.txt
echo data- $DATAPATH to- $WRITEDIR dir- $DIRNAME file- $FILENAME 
md5sum $WRITEDIR/$FILENAME > $WRITEDIR/$FILENAME.MD5 
cat $WRITEDIR/$FILENAME.MD5
module load Python/3.11.5-GCCcore-13.2.0
python3 scripts/shareLink.py $KEYMINIO Data $FILENAME
# bash scripts/backUpPD.sh 190820_Camilla_wolo


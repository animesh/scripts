mkdir -p $HOME/promec/promec/TIMSTOF/LARS/2026/260211_Steven/
#winZipDir.bat L:\promec\TIMSTOF\LARS\2026\260211_Steven
rclone ls --include "**.zip" NS9036K:PD/TIMSTOF/LARS/2026/260211_Steven/ 
rclone copy -Pv --include "**.zip" NS9036K:PD/TIMSTOF/LARS/2026/260211_Steven/ $HOME/promec/promec/TIMSTOF/LARS/2026/260211_Steven/
ls $HOME/promec/promec/TIMSTOF/LARS/2026/260211_Steven/*.zip
pip3 install pride-checksum
pride_checksum --out_path $PWD --files_dir  $HOME/promec/promec/TIMSTOF/LARS/2026/260211_Steven/
mkdir 260408_Steven
pride_checksum --out_path $PWD/260408_Steven/ --files_dir  $HOME/promec/promec/TIMSTOF/LARS/2026/260408_Steven
mkdir 260805_Nelly
pride_checksum --out_path $PWD/260805_Nelly/ --files_dir  $HOME/promec/promec/TIMSTOF/LARS/2026/260805_Nelly
pride_checksum --out_path $HOME/promec/os/ --files_dir  $HOME/promec/os/
cp $PWD/260805_Nelly/checksum.txt  $HOME/promec/promec/TIMSTOF/LARS/2026/260805_Nelly
cp $PWD/260408_Steven/checksum.txt  $HOME/promec/promec/TIMSTOF/LARS/2026/260408_Steven/.
cp $PWD/checksum.txt  $HOME/promec/promec/TIMSTOF/LARS/2026/260211_Steven/.
pip3 install sdrf-pipelines # --break-system-packages
#parse_sdrf validate-sdrf --sdrf_file $HOME/promec/os/Sample_table_THE1.sdrf.tsv #https://www.ebi.ac.uk/pride/services/sdrf-validator
pride_checksum --out_path $HOME/promec/os/ --files_dir  $HOME/promec/os/
#cat $HOME/promec/os/checksum.txt

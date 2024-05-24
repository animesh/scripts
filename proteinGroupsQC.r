#Rscript proteinGroupsQC.r "L:/promec/TIMSTOF/LARS/2023/230310 ChunMei/combined/txt/"
#setup####
if(!require("PTXQC")){print("Package 'PTXQC' is not installed. Installing...");install.packages("PTXQC")}
args = commandArgs(trailingOnly=TRUE)
print(paste("supplied argument(s):", length(args)))
print(args)
inpD <- args[1]
#inpD<-"L:/promec/TIMSTOF/LARS/2023/230310 ChunMei/combined/txt/
#data####
#for i in TIMSTOF/LARS/2023/230310\ ChunMei/*.d ; do echo $i ; ls "$i" ; tar cvf "$i.tar" "$i" ; done
#mkdir -p promec/promec/TIMSTOF/LARS/2023/230310\ ChunMei/combined/txt/
#rsync -Parv ash022@login1.nird-lmd.sigma2.no:TIMSTOF/LARS/2023/230310\\\ ChunMei/*.tar promec/TIMSTOF/LARS/2023/230310\ ChunMei/.
#rsync -Parv --min-size=1  --exclude=.gd --exclude=.tmp.driveupload  ash022@login1.nird-lmd.sigma2.no:TIMSTOF/LARS/2023/230310\\\ ChunMei/combined/txt/ promec/TIMSTOF/LARS/2023/230310\ ChunMei/combined/txt/
#scp ash022@login1.nird-lmd.sigma2.no:TIMSTOF/LARS/2023/230310\\\ ChunMei/mqpar.xml promec/TIMSTOF/LARS/2023/230310\ ChunMei/combined/txt/.
#QC####
cat(paste0("\nPTXQC was installed to '", .libPaths()[1], "'.\n\n"))
library("PTXQC")
createReport(inpD)
#check for peptides -> sequence with git clone https://github.com/pierrepeterlongo/kmer2sequences.git
#kmer2sequences/kmer2sequences -k 6 -i 1 -o 1 -f 1 -s 1 -t 1 -m 1 -n 1 -r 1 -l 1 -d 1 -c 1 -a 1 -b 1 -g 1 -e 1 -j 1 -p 1 -q 1 -u 1 -v 1 -w 1 -x 1 -y 1 -z 1 -A 1 -B 1 -C 1 -D 1 -E 1 -F 1 -G 1 -H 1 -I 1 -J 1 -K 1 -L 1 -M 1 -N 1 -O 1 -P 1 -Q 1 -R 1 -S 1 -T 1 -U 1 -V 1 -W 1 -X 1 -Y 1 -Z 1 -0 1 -1 1 -2 1 -3 1 -4 1 -5 1 -6 1 -7 1 -8 1 -9 1 -! 1 -@ 1 -# 1 -$ 1 -% 1 -^ 1 -& 1 -* 1 -\( 1 -\) 1 -_ 1 -+ 1 -= 1 -{ 1 -} 1 -[ 1 -] 1 -| 1 -; 1 -: 1 -' 1 -" 1 -< 1 -> 1 -, 1 -. 1 -/ 1 -?

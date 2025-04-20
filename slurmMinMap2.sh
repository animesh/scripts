#git checkout d0c2421846c29bbb3facddd46b16511f4537649b scratch.slurm
#wget https://github.com/lh3/minimap2/releases/download/v2.29/minimap2-2.29_x64-linux.tar.bz2
#tar xvjf minimap2-2.29_x64-linux.tar.bz2 
#cp minimap2-2.29_x64-linux /cluster/projects/nn9036k/
#dos2unix slurmMinMap2.sh scratch.slurm
#bash slurmMinMap2.sh /cluster/projects/nn9036k/TK
#/cluster/projects/nn9036k/minimap2-2.29_x64-linux/minimap2 -ax splice:sr -t80 /cluster/projects/nn9036k/hg38v110/genome.fa /cluster/projects/nn9036k/TK/TK10_49_1.fq.gz /cluster/projects/nn9036k/TK/TK10_49_2.fq.gz | samtools sort -@4 -m4g -o TK10_49.bam -
#[M::main] Real time: 659.985 sec; CPU: 30093.450 sec; Peak RSS: 24.207 GB
#[bam_sort_core] merging from 1 files and 4 in-memory blocks...                                                                     
#rename '__.1P.fq.gz' '_1.fastq.gz' /cluster/home/ash022/scripts/TK9/trimmomatic.1701618021.results/*
#rename '__.2P.fq.gz' '_2.fastq.gz' /cluster/home/ash022/scripts/TK9/trimmomatic.1701618021.results/*
#curl -L https://github.com/attractivechaos/k8/releases/download/v0.2.4/k8-0.2.4.tar.bz2 | tar -jxf -
#cp -rf k8-0.2.4 /cluster/projects/nn9036k/
#export PATH=$PATH:/cluster/projects/nn9036k/k8-0.2.4
#/cluster/projects/nn9036k/k8-0.2.4/k8-Linux /cluster/projects/nn9036k/minimap2-2.29_x64-linux/paftools.js gff2bed /cluster/projects/nn9036k/hg38v110/Homo_sapiens.GRCh38.110.gtf  > /cluster/projects/nn9036k/hg38v110/gencode.bed
DATADIR=$1
RUNCMD=minimap2
PARAMFILE=scratch.slurm
CURRENTEPOCTIME=`date +%s`
WRITEDIR=$RUNCMD.$CURRENTEPOCTIME
for i in $DATADIR/*_1.fq.gz ; do echo $i; i2=${i/%1.fq.gz/2.fq.gz} ; echo $i2; j=$(basename $i); echo $j; k=${j%%1.fq.gz}; echo  $k ; sed "s|seqRNA|$k.$RUNCMD.$CPU|g" $PARAMFILE > $DATADIR/$WRITEDIR.$PARAMFILE.tmp1 ; 	sed "s|FASTFILE1|$i|"  $DATADIR/$WRITEDIR.$PARAMFILE.tmp1 > $DATADIR/$WRITEDIR.$PARAMFILE.tmp2 ;  sed "s|FASTFILE2|$i2|"  $DATADIR/$WRITEDIR.$PARAMFILE.tmp2 > $DATADIR/$WRITEDIR.$PARAMFILE.tmp3 ;  sed "s|FASTFILE|$DATADIR/$WRITEDIR.$k|g"  $DATADIR/$WRITEDIR.$PARAMFILE.tmp3 > $DATADIR/$WRITEDIR.$k.$PARAMFILE ; rm $DATADIR/$WRITEDIR.$PARAMFILE.tmp*  ; cat $DATADIR/$WRITEDIR.$k.$PARAMFILE ; echo $DATADIR/$WRITEDIR.$k.$PARAMFILE  ; sbatch $DATADIR/$WRITEDIR.$k.$PARAMFILE  ; done
ls -ltrh $DATADIR/$WRITEDIR*$PARAMFILE
squeue -u ash022



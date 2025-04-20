#git checkout d0c2421846c29bbb3facddd46b16511f4537649b scratch.slurm
#wget https://github.com/lh3/minimap2/releases/download/v2.29/minimap2-2.29_x64-linux.tar.bz2
#tar xvjf minimap2-2.29_x64-linux.tar.bz2 
#cp minimap2-2.29_x64-linux /cluster/projects/nn9036k/
#dos2unix slurmMinMap2.sh scratch.slurm
#bash slurmMinMap2.sh
module load SAMtools/1.19.2-GCC-13.2.0
/cluster/projects/nn9036k/minimap2-2.29_x64-linux/minimap2 -ax splice:sr -t80 /cluster/projects/nn9036k/hg38v110/genome.fa /cluster/projects/nn9036k/TK/TK10_49_1.fq.gz /cluster/projects/nn9036k/TK/TK10_49_2.fq.gz | samtools sort -@4 -m4g -o TK10_49.bam -
#/cluster/projects/nn9036k/minimap2-2.29_x64-linux/minimap2 -ax splice:sr -t80 /cluster/projects/nn9036k/hg38v110/genome.fa /cluster/projects/nn9036k/TK/TK10_49_1.fq.gz /cluster/projects/nn9036k/TK/TK10_49_2.fq.gz #https://lh3.github.io/2025/04/18/short-rna-seq-read-alignment-with-minimap2?s=09
#[M::main] Real time: 659.985 sec; CPU: 30093.450 sec; Peak RSS: 24.207 GB
#[bam_sort_core] merging from 1 files and 4 in-memory blocks...
#rename '__.1P.fq.gz' '_1.fastq.gz' /cluster/home/ash022/scripts/TK9/trimmomatic.1701618021.results/*
#rename '__.2P.fq.gz' '_2.fastq.gz' /cluster/home/ash022/scripts/TK9/trimmomatic.1701618021.results/*

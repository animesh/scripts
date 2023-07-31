#!/bin/sh
##SBATCH --partition=bigmem
#SBATCH --account=nn9036k --job-name=starBAMQISLURMJOB
##SBATCH --account=nn9036k --job-name=SLURMJOBBM
#SBATCH --time=48:00:00
#SBATCH --mail-user=animesh.sharma@ntnu.no
##SBATCH --ntasks=1 --cpus-per-task=16 --ntasks-per-node=4
##SBATCH --mem-per-cpu=16G
#SBATCH --ntasks=1 --cpus-per-task=10
#SBATCH --mem-per-cpu=4G
#SBATCH --mail-type=ALL
#SBATCH --output=QIlog

WORKDIR=${SLURM_SUBMIT_DIR}
cd ${WORKDIR}
export PATH=$PATH:$PWD
echo "we are running from this directory: $SLURM_SUBMIT_DIR"
echo " the name of the job is: $SLURM_JOB_NAME"
echo "Th job ID is $SLURM_JOB_ID"
echo "The job was run on these nodes: $SLURM_JOB_NODELIST"
echo "Number of nodes: $SLURM_JOB_NUM_NODES"
echo "We are using $SLURM_CPUS_ON_NODE cores"
echo "We are using $SLURM_CPUS_ON_NODE cores per node"
echo "Total of $SLURM_NTASKS cores"

export http_proxy=proxy.saga:3128
export https_proxy=proxy.saga:3128

module purge
module load  Qualimap/2.3-foss-2022b-R-4.2.2 

#qualimap -h
#qualimap --java-mem-size=64G bamqc -nt 6 -bam cluster/rnaSeqChk/hisat2.1688721150.results/WT_1_R1.sam
#qualimap --java-mem-size=40G bamqc -bam scripts/TK/star.1690114446.results/*.bam -outdir R49/bamqc -outformat PDF:HTML
#qualimap --java-mem-size=40G rnaseq -a uniquely-mapped-reads -bam scripts/TK/star.1690114446.results/TK10_49_len150Aligned.sortedByCoord.out.bam -gtf scripts/hg38v110star/Homo_sapiens.GRCh38.110.gtf -oc TK10_49.out -outdir $PWD  -outformat PDF:HTML -p non-strand-specific  -pe -s
#qualimap --java-mem-size=40G rnaseq -bam scripts/TK/star.1690114446.results/TK10_49_len150Aligned.sortedByCoord.out.bam -gtf scripts/hg38v110star/Homo_sapiens.GRCh38.110.gtf -oc TK10_49.out -outdir $PWD/R49  -outformat PDF:HTML -p non-strand-specific  -pe -s
#ls /cluster/projects/nn9036k/scripts/TK/hisat2.1690116069.results/samtools.1690117388.results/*.sort.bam  > bamFP
#cat bamFP  | awk -F '/' '{print $9}' | awk -F '.' '{print $1}' > sampleName
#cat sampleName | awk -F '_' '{print $1}' > groupName
#paste sampleName bamFP groupName > TK/dataTK.qi.hisat2.list
#qualimap --java-mem-size=40G multi-bamqc -r -d $PWD/TK/dataTK.qi.list -gff $PWD/hg38v110star/Homo_sapiens.GRCh38.110.gtf -outdir $PWD/TK/multibamqc -outformat PDF:HTML
#qualimap --java-mem-size=40G multi-bamqc -r -d $PWD/TK/dataTK.qi.hisat2.list -gff $PWD/hg38v110/Homo_sapiens.GRCh38.110.gtf -outdir $PWD/TK/multibamqcHISAT2slurm -outformat PDF:HTML
qualimap --java-mem-size=40G multi-bamqc -r -d $PWD/TK/dataTK.qi.list -gff $PWD/hg38v110star/Homo_sapiens.GRCh38.110.gtf -outdir $PWD/TK/multibamqcSTARslurm -outformat PDF:HTML


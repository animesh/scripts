#!/bin/sh
##SBATCH --partition=bigmem
#SBATCH --account=nn9036k --job-name=seqRNA
##SBATCH --account=nn9036k --job-name=seqRNABM
#SBATCH --time=1:00:00
#SBATCH --mail-user=animesh.sharma@ntnu.no
##SBATCH --ntasks=1 --cpus-per-task=16 --ntasks-per-node=4
##SBATCH --mem-per-cpu=16G
#SBATCH --ntasks=4 --cpus-per-task=10 --ntasks-per-node=4
#SBATCH --mem-per-cpu=1G
#SBATCH --mail-type=ALL
#SBATCH --output=seqRNAlog

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
#export LMOD_DISABLE_SAME_NAME_AUTOSWAP=FALSE
export http_proxy=proxy.saga:3128
export https_proxy=proxy.saga:3128
module purge
module load STAR/2.7.10b-GCC-11.3.0
#STAR --genomeDir STARGENOMEDIR/ \
STAR --genomeDir /cluster/home/ash022/scripts/hg38v110star/hg38_index_len150/ \
	--runThreadN 40 \
	--readFilesIn FASTFILE1 FASTFILE2 \
	--quantMode GeneCounts \
	--readFilesCommand zcat \
	--outFileNamePrefix FASTFILElen150 \
	--outSAMtype BAM SortedByCoordinate \
	--outSAMunmapped Within \
	--outSAMattributes Standard 

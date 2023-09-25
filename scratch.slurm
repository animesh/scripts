#!/bin/sh
##SBATCH --partition=bigmem
#SBATCH --account=nn9036k --job-name=seqRNAtrim
##SBATCH --account=nn9036k --job-name=seqRNABMtrim
#SBATCH --time=1:00:00
#SBATCH --mail-user=animesh.sharma@ntnu.no
##SBATCH --ntasks=1 --cpus-per-task=10 --ntasks-per-node=1
##SBATCH --mem-per-cpu=4G
#SBATCH --ntasks=1 --cpus-per-task=10
#SBATCH --mem-per-cpu=4G
#SBATCH --mail-type=ALL
#SBATCH --output=seqRNAtrimlog

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
module load Trimmomatic/0.39-Java-11

java -jar -Xmx40G $EBROOTTRIMMOMATIC/trimmomatic-0.39.jar PE -threads 10 -phred33 -trimlog FASTFILE.trimLog.txt -summary FASTFILE.trimSummary.txt -validatePairs P1FASTFILE P2FASTFILE PD1FASTFILE.1P.fq.gz PD1FASTFILE.1U.fq.gz  PD2FASTFILE.2P.fq.gz PD2FASTFILE.2U.fq.gz ILLUMINACLIP:$EBROOTTRIMMOMATIC/adapters/NexteraPE-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:30


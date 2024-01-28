#!/bin/sh
#SBATCH --account=nn9036k --job-name=RNASEQNFTOWER
#SBATCH --time=24:00:00
##SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=20
#SBATCH --mem-per-cpu=8G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=RNASEQNFTOWER

WORKDIR=$PWD
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
module load Miniconda3/22.11.1-1
#conda config --prepend channels bioconda
#conda config --show channels
#mamba install python=3.11 nf-core nextflow
#nf-core create
#cd nf-core-spritz/
#git checkout dev
#git remote add origin https://github.com/animesh/spritz_nf.git
#git push --all origin
conda activate nf-core
#nextflow  self-update
nextflow  -v
#set env for -with-tower from https://tower.nf/
export TOWER_ACCESS_TOKEN=$TOWER_ACCESS_TOKEN
#uniq -name for each run
CURRENTEPOCTIME=`date +%s`
nextflow run 'https://github.com/nf-core/rnaseq' -r 3.14.0 -profile singularity  -params-file nextflow.json  -with-tower --outdir RNASEQNFTOWER_$CURRENTEPOCTIME -resume




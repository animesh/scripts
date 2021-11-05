#!/bin/sh
#SBATCH --account=nn9036k --job-name=atlas
#SBATCH --partition=bigmem
#SBATCH --time=216:15:30
#SBATCH --ntasks=16 --cpus-per-task=1
#SBATCH --mem-per-cpu=64G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#$BATCH --output=srun.out


WORKDIR=${SLURM_SUBMIT_DIR}
cd ${WORKDIR}
export PATH=$PATH:$PWD
echo "mamba create -n mga28  python=3.8"
echo "conda activate mga28"
echo "mamba install -c bioconda -c conda-forge metagenome-atlas=2.8"
echo "cd /cluster/projects/nn9036k/readz"
echo "atlas init --db-dir databases /cluster/projects/nn9036k/reads"
cat samples.tsv
cat config.yaml
echo $PATH
echo "we are running from this directory: $SLURM_SUBMIT_DIR"
echo " the name of the job is: $SLURM_JOB_NAME"
echo "Th job ID is $SLURM_JOB_ID"
echo "The job was run on these nodes: $SLURM_JOB_NODELIST"
echo "Number of nodes: $SLURM_JOB_NUM_NODES"
echo "We are using $SLURM_CPUS_ON_NODE cores"
echo "We are using $SLURM_CPUS_ON_NODE cores per node"
echo "Total of $SLURM_NTASKS cores"

module purge
conda activate mga28
export http_proxy=proxy.saga:3128
export https_proxy=proxy.saga:3128

atlas run all --resources mem=1024 --jobs 16

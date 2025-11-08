#!/bin/sh
#SBATCH --account=nn9036k --job-name=rustBMppm15DIAfX
#SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=32
#SBATCH --mem-per-cpu=8G
#SBATCH --time=12:00:00
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=rustBMhumppm15DIAfX.log
#git clone https://github.com/lazear/sage.git
#cd sage
#module swap GCCcore/13.2.0 GCCcore/13.3.0
cd /cluster/projects/nn9036k/sage/
export PATH=$PATH:$PWD
echo "we are running from this directory: $SLURM_SUBMIT_DIR"
echo " the name of the job is: $SLURM_JOB_NAME"
echo "Th job ID is $SLURM_JOB_ID"
echo "The job was run on these nodes: $SLURM_JOB_NODELIST"
echo "Number of nodes: $SLURM_JOB_NUM_NODES"
echo "We are using $SLURM_CPUS_ON_NODE cores"
echo "We are using $SLURM_CPUS_ON_NODE cores per node"
echo "Total of $SLURM_NTASKS cores"
module purge
module load Rust/1.83.0-GCCcore-13.3.0
#dos2unix slurmDIANN.sh scratch.slurm
#cargo run --release tests/config.json
conda activate sage
#mamba install -c bioconda -c conda-forge sage-proteomics
sage /cluster/home/ash022/cluster/scripts/sage.json 
#rsync -Parv /nird/projects/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2025/251031_MAREN/251030_MAREN_DIALYSE_DIA_Slot1-37_1_11509.d/251030_maren_DIA.mzML .

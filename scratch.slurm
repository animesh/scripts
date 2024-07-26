#!/bin/sh
#SBATCH --account=nn9036k --job-name=timsConvert
#SBATCH --time=24:00:00
##SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=1
#SBATCH --mem-per-cpu=16G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=timsConvertLog
WORKDIR=$PWD
cd ${WORKDIR}
echo "we are running from this directory: $SLURM_SUBMIT_DIR"
echo " the name of the job is: $SLURM_JOB_NAME"
echo "Th job ID is $SLURM_JOB_ID"
echo "The job was run on these nodes: $SLURM_JOB_NODELIST"
echo "Number of nodes: $SLURM_JOB_NUM_NODES"
echo "We are using $SLURM_CPUS_ON_NODE cores"
echo "We are using $SLURM_CPUS_ON_NODE cores per node"
echo "Total of $SLURM_NTASKS cores"
module purge
#https://gtluu.github.io/timsconvert/local.html#basic-example
#conda create -n timsconvert python=3.11
conda activate timsconvert
#pip install -r https://raw.githubusercontent.com/gtluu/timsconvert/main/requirements.txt
#pip install git+https://github.com/gtluu/timsconvert
for i in /cluster/work/users/ash022/veronica/*He*.d ; do echo $i ; timsconvert --chunk_size 10000000 --imzml_mode continuous --verbose --input $i ;  done


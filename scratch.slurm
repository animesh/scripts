#!/bin/sh
#SBATCH --account=nn9036k --job-name=MQSLURMNAME
#SBATCH --time=160:00:00
#SBATCH --ntasks=1 --cpus-per-task=20
#SBATCH --mem-per-cpu=8G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=MQSLURMLOG
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
#export LMOD_DISABLE_SAME_NAME_AUTOSWAP=no
#module load Boost/1.83.0-GCC-13.2.0
/cluster/projects/nn9036k/dotnet80303/dotnet --version
/cluster/projects/nn9036k/dotnet80303/dotnet /cluster/home/ash022/scripts/MaxQuant_v2.7.5.0/bin/MaxQuantCmd.dll  /cluster/work/users/ash022/edan/mqpar.xml
#wget https://maxquant.org/p/maxquant/MaxQuant_v2.7.5.0.zip?md5=4zpRvQXl5wJA5hHFcXzfSg&expires=1761732705


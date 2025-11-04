#!/bin/sh
#SBATCH --account=nn9036k --job-name=alphaDIAtestPatch
##SBATCH --partition=bigmem
#SBATCH --time=4:00:00
#SBATCH --ntasks=1 --cpus-per-task=20
#SBATCH --mem-per-cpu=8G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=alphaDIAtestSLURMLOGpatch.txt

#conda create -n alphadia -y
#conda activate alphadia
#conda install python=3.11 -y
#mamba install mono=6.12.0.182 -c anaconda -y
#pip install "alphadia[stable]"
#mkdir -p /cluster/home/ash022/peptdeep/pretrained_models
#cd /cluster/home/ash022/peptdeep/pretrained_models
#wget https://github.com/MannLabs/alphapeptdeep/releases/download/pre-trained-models/pretrained_models.zip
#wget https://raw.githubusercontent.com/MannLabs/alphadia/refs/heads/main/tests/e2e_tests/e2e_slurm.sh

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
#pip install cassanovo
/cluster/home/ash022/.local/bin/casanovo sequence 251030_MAREN_DIALYSE_DDA_Slot1-37_1_11507_6.1.452.mgf


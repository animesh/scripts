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
# input parameters:
CONDA_ENV=alphadia
BRANCH=main  # branch to take test cases from
TEST_CASE=basic

#
set -u -e
OUTPUT_FOLDER=output_${CONDA_ENV}_${TEST_CASE}_${SLURM_JOB_ID}
URL=https://raw.githubusercontent.com/MannLabs/alphadia/${BRANCH}/tests
export TQDM_MININTERVAL=10  # avoid lots of tqdm outputs

echo CONDA_ENV=$CONDA_ENV
echo BRANCH=$BRANCH
echo OUTPUT_FOLDER=$OUTPUT_FOLDER

echo CONDA_ENV ">>>>>>"
conda info
conda run -n $CONDA_ENV pip freeze
echo "<<<<<<"

echo MONO_VERSION ">>>>>>"
conda run -n $CONDA_ENV mono --version
echo "<<<<<<"

echo "Preparing test data.."

mkdir -p $OUTPUT_FOLDER && cd $OUTPUT_FOLDER

# note: if the locations of these files change, this script will need to be updated
wget $URL/run_e2e_tests.sh

mkdir -p e2e_tests && cd e2e_tests
wget $URL/e2e_tests/e2e_test_cases.yaml
wget $URL/e2e_tests/prepare_test_data.py
#wget $URL/e2e_tests/calc_metrics.py
wget https://raw.githubusercontent.com/MannLabs/alphadia/55b3567e9759c97c48471ba50ea08daa9eb30ca3/tests/e2e_tests/calc_metrics.py

cd ..

chmod +x ./run_e2e_tests.sh

echo "Running alphadia.."
./run_e2e_tests.sh $TEST_CASE $CONDA_ENV


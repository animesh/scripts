#!/bin/sh
#SBATCH --account=nn9036k --job-name=BPTK
#SBATCH --time=48:00:00
##SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=10
#SBATCH --mem-per-cpu=4G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=nfSLURMLOG


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
conda activate bamplot
#conda install -c bioconda perbase
#pip install bam2plot
#rm -rf output_folder/
#cd $PWD/TK/mergeHISAT
for i in *.sort.bam ; do echo $i; rm -f *.sorted.bam.tmp.* ; bam2plot --bam $i  -i True -s True --sample_name sample.$i --outpath output.$i ; done






#!/bin/sh
##SBATCH --partition=bigmem
#SBATCH --account=nn9036k --job-name=SLURMJOB
##SBATCH --account=nn9036k --job-name=SLURMJOBBM
#SBATCH --time=48:00:00
#SBATCH --mail-user=animesh.sharma@ntnu.no
##SBATCH --ntasks=1 --cpus-per-task=16 --ntasks-per-node=4
##SBATCH --mem-per-cpu=16G
#SBATCH --ntasks=4 --cpus-per-task=10
#SBATCH --mem-per-cpu=4G
#SBATCH --mail-type=ALL
#SBATCH --output=SLURMJOBlog
##cd /cluster/home/ash022/scripts/Spritz/Spritz/workflow
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
#module load Miniconda3/22.11.1-1
#mamba install -y yaml
conda activate spritzbase
#conda install -c anaconda pyyaml 
snakemake -j 40  --unlock
#snakemake -j 16 --use-conda --conda-frontend mamba --resources mem_mb=64000
snakemake -j 40 --use-conda --conda-frontend mamba --resources mem_mb=160000 --rerun-incomplete 
#cd /cluster/projects/nn9036k/Spritz/Spritz/workflow
#conda activate spritzbase
#mkdir $HOME/scripts/TK/fastq/TK9/TK9_3_22GH5GLT3_GGCGCCATTG-ACCGCGCAAT_L002
#ln -s $HOME/scripts/TK/fastq/TK9/TK9_3_22GH5GLT3_GGCGCCATTG-ACCGCGCAAT_L002_R1.fastq $HOME/scripts/TK/fastq/TK9/TK9_3_22GH5GLT3_GGCGCCATTG-ACCGCGCAAT_L002/TK9_3_22GH5GLT3_L2_1.fastq
#ln -s $HOME/scripts/TK/fastq/TK9/TK9_3_22GH5GLT3_GGCGCCATTG-ACCGCGCAAT_L002_R2.fastq $HOME/scripts/TK/fastq/TK9/TK9_3_22GH5GLT3_GGCGCCATTG-ACCGCGCAAT_L002/TK9_3_22GH5GLT3_L2_2.fastq
#ls $HOME/scripts/TK/fastq/TK9/TK9_3_22GH5GLT3_GGCGCCATTG-ACCGCGCAAT_L002
#vim config/config.yaml
#tail -f SLURMJOBlog
#cd $HOME/scripts
#cp /cluster/projects/nn9036k/Spritz/Spritz/workflow/scratch.slurm .
#cp /cluster/projects/nn9036k/Spritz/Spritz/workflow/config/config.yaml config.spritz


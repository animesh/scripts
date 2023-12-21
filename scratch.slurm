#!/bin/sh
#SBATCH --partition=bigmem
#SBATCH --account=nn9036k --job-name=SLURMJOB
#SBATCH --time=92:00:00
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --ntasks=1 --cpus-per-task=32 --ntasks-per-node=1
#SBATCH --mem-per-cpu=8G
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
module load Miniconda3/22.11.1-1
#mamba install -y yaml
conda activate spritzbase
#conda install -c anaconda pyyaml 
snakemake -j 40  --unlock
#snakemake -j 16 --use-conda --conda-frontend mamba --resources mem_mb=64000
snakemake -j 64 --use-conda --conda-frontend mamba --resources mem_mb=256000 --rerun-incomplete 
#cd $HOME/scripts
#cp /cluster/projects/nn9036k/Spritz/Spritz/workflow/scratch.slurm .
#cp /cluster/projects/nn9036k/Spritz/Spritz/workflow/config/config.yaml .
#cd /cluster/home/ash022/scripts/TK/fastq/TK9
#mkdir TK9_1_22GH5GLT3_AGAGAACCTA-GGTTATGCTA_L003
#ln -s $PWD/TK9_1_22GH5GLT3_AGAGAACCTA-GGTTATGCTA_L003_R2.fastq $PWD/TK9_1_22GH5GLT3_AGAGAACCTA-GGTTATGCTA_L003/TK9_1_22GH5GLT3_AGAGAACCTA-GGTTATGCTA_L003_2.fastq
#ln -s $PWD/TK9_1_22GH5GLT3_AGAGAACCTA-GGTTATGCTA_L003_R1.fastq $PWD/TK9_1_22GH5GLT3_AGAGAACCTA-GGTTATGCTA_L003/TK9_1_22GH5GLT3_AGAGAACCTA-GGTTATGCTA_L003_1.fastq
#cd /cluster/projects/nn9036k/Spritz/Spritz/workflow
#vim config/config.yaml
#cd $HOME/scripts
#cp /cluster/projects/nn9036k/Spritz/Spritz/workflow/scratch.slurm .
#cp /cluster/projects/nn9036k/Spritz/Spritz/workflow/config/config.yaml config.spritz



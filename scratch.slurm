#!/bin/sh
#SBATCH --account=nn9036k --job-name=DANFTOWER
#SBATCH --time=2:00:00
##SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=20
#SBATCH --mem-per-cpu=8G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=DANFTOWER

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
#nextflow pull nf-core/differentialabundance ## com for reproducibility
#set env for -with-tower from https://tower.nf/
export TOWER_ACCESS_TOKEN=$TOWER_ACCESS_TOKEN
#uniq -name for each run
CURRENTEPOCTIME=`date +%s`
#wget https://ftp.ensembl.org/pub/release-111/gtf/mus_musculus/Mus_musculus.GRCm39.111.gtf.gz
#gunzip Mus_musculus.GRCm39.111.gtf.gz 
nextflow run nf-core/differentialabundance -r 1.4.0 --max_memory '80.GB' --max_cpus 20  --input AMHCSTNTCsamples.csv --contrasts AMHCSTNTCcontrasts.csv --matrix AMHCSTNTClog2LFQ.tsv --gtf /cluster/projects/nn9036k/scripts/Mus_musculus.GRCm39.111.gtf  -profile singularity -name slurm_$CURRENTEPOCTIME -with-tower --outdir DANFTOWER_$CURRENTEPOCTIME



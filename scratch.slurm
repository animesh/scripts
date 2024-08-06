#!/bin/sh
#SBATCH --account=nn9036k --job-name=denovotranscript
#SBATCH --time=160:00:00
##SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=7
#SBATCH --mem-per-cpu=8G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=denovotranscriptLog
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
#https://github.com/nf-core/denovotranscript
#curl -fsSL get.nextflow.io | bash
#nextflow  -v
#./nextflow self-update
nextflow  -v
#mkdir /cluster/projects/nn9036k/TK
cd /cluster/projects/nn9036k/TK
#rsync -Parv   ash022@login.nird-lmd.sigma2.no:PD/Animesh/TK/*16*g*z .
#echo "sample,fastq_1,fastq_2" > samples.csv
#ls -1 *1.fq.gz | awk -F '_' '{print $1$2}' > S1
#ls -1 $PWD/*1.fq.gz > S1
#ls -1 $PWD/*2.fq.gz > S2
#ls -1 *1.fq.gz | awk -F '_' '{print $1$2}' > S0
#paste -d ','  S? >> samples.csv
cat samples.csv
./nextflow run nf-core/denovotranscript --max_memory '56.GB' --max_cpus 7  -profile singularity --input samples.csv --outdir DNT  -resume
#https://nf-co.re/denovotranscript/dev/docs/output/


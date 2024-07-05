#!/bin/sh
#SBATCH --account=nn9036k --job-name=jana
#SBATCH --time=160:00:00
#SBATCH --partition=bigmem
#SBATCH --ntasks=4 --cpus-per-task=10
#SBATCH --mem-per-cpu=4G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=janaLog
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
module load Java/17.0.4
#curl -s https://get.nextflow.io | bash
#chmod +x nextflow
#nextflow info
#nextflow self-update
#cred https://cloud.seqera.io/orgs/NTNU/workspaces/TK/watch/5E1kiJpSRASBe4
#tw --access-token=<your access token> <other options> https://github.com/seqeralabs/tower-cli/?tab=readme-ov-file
nextflow run 'https://github.com/nf-core/rnaseq' -name modest_kirch -params-file nextflow.json -with-tower -r 3.14.0  -profile singularity
#rsync -Parv   ash022@login.nird-lmd.sigma2.no:DL/RNASEQ/7z/GCF-2024-931 .
#cd /cluster/work/users/ash022/jana/GCF-2024-931
#ls -1 $PWD/*2.fastq.gz > S2
#ls -1 $PWD/*1.fastq.gz > S1
#printf 'auto\n%.0s' {1..12} > S3
#ls -1 *R1.fastq.gz | awk -F '_' '{print $1}' > S0
#echo "sample,fastq_1,fastq_2,strandedness" > samples.csv
#paste -d "," S? >> samples.csv
#cat samples.csv
#mkdir tower_TK12_3p14
#cat /cluster/work/users/ash022/jana/GCF-2024-931/samples.csv
#ls /cluster/work/users/ash022/jana/GCF-2024-931/tower_TK12_3p14
#wc /cluster/projects/nn9036k/scripts/hg38v110/genome.fa
#wc /cluster/projects/nn9036k/scripts/hg38v110/Homo_sapiens.
#ls tower_TK12_3p14/



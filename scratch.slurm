#!/bin/sh
#SBATCH --account=nn9036k --job-name=DNT
#SBATCH --time=160:00:00
#SBATCH --ntasks=1 --cpus-per-task=10
#SBATCH --mem-per-cpu=4G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=DNTSLURMLOG

WORKDIR=/cluster/work/users/ash022/work
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
# compute slurm_40_www
nextflow run 'https://github.com/nf-core/denovotranscript' -name fervent_lavoisier -params-file 'https://api.cloud.seqera.io/ephemeral/ZfYCAN5Dr0uazMVFVsg8vA.json' -with-tower -r 558ff4b639039ac8ec9bece3490841aa17eec971 -profile singularity
# id 1hyljd0K8cTkUZ 2024-08-19 11:38:44 558ff4b639039ac8ec9bece3490841aa17eec971 (1.0.0) d62c33e7-9fac-4b9d-a2b8-910d1b40cd55
# 23.10.1 build 5891

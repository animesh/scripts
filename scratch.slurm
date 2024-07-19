#!/bin/sh
#SBATCH --account=nn9036k --job-name=sage
#SBATCH --time=24:00:00
##SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=20
#SBATCH --mem-per-cpu=8G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=sageLog
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
#https://sage-docs.vercel.app/docs/configuration/example_PXD003881
#conda create -n sage
conda activate sage
#conda install -c bioconda -c conda-forge sage-proteomics
#conda activate timsconvert
#pip install -r https://raw.githubusercontent.com/gtluu/timsconvert/main/requirements.txt
#pip install git+https://github.com/gtluu/timsconvert
#for i in /cluster/work/users/ash022/veronica/*He*.d ; do echo $i ; timsconvert --chunk_size 5000000000 --verbose --input $i ;  done
#grep "^>" human_crap.fasta | wc
# 104718 1220815 11130457
# (sage) [ash022@login-1.SAGA ~/scripts]$ grep "^>" human.fasta | wc
#  104602 1220699 11128482
#  (sage) [ash022@login-1.SAGA ~/scripts]$ grep "^>" crap.fasta | wc
#      116     116    1975
#  1032  2024-07-19T10:23:05 wget "https://rest.uniprot.org/uniprotkb/stream?format=fasta&includeIsoform=true&query=%28%28proteome%3AUP000005640%29%29" -O human.fasta
#    1034  2024-07-19T10:25:24 wget "http://ftp.thegpm.org/fasta/cRAP/crap.fasta" -O crap.fasta
#     1035  2024-07-19T10:25:45 cat human.fasta crap.fasta >> human_crap.fasta
sage sage.json -f human_crap.fasta --batch-size 40 /cluster/work/users/ash022/*.mzML
ls -ltrh lfq.tsv results.json  results.sage.tsv
cat results.json
wc lfq.tsv
wc results.sage.tsv


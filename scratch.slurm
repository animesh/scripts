#!/bin/sh
#SBATCH --account=nn9036k --job-name=ppm15DIAfX
#SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=32
#SBATCH --mem-per-cpu=32G
#SBATCH --time=96:00:00
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=ppm15DIAfX.log
#wget https://github.com/vdemichev/DiaNN/releases/download/2.0/DIA-NN-2.3.0-Academia-Linux-Preview.zip
#sha256sum DIA-NN-2.3.0-Academia-Linux-Preview.zip
#sha256:1971187adbe81964923517db4c2d29703787a67686dfc6899a01f7337a39d0a4
#unzip DIA-NN-2.3.0-Academia-Linux-Preview.zip
#cp -rf diann-2.3.0 /cluster/projects/nn9036k/.
#chmod 755 /cluster/projects/nn9036k/diann-2.3.0/diann-linux
#cp -rf /nird/projects/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/FastaDB/UP000005640_9606_1protein1gene*fasta /cluster/projects/nn9036k/diann-2.3.0/.
#cp -rf /nird/projects/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2025/251031_MAREN/251030_MAREN_DIALYSE_DDA_Slot1-37_1_11507.d /cluster/projects/nn9036k/diann-2.3.0/.
cd /cluster/projects/nn9036k/diann-2.2.0/
export PATH=$PATH:$PWD
echo "we are running from this directory: $SLURM_SUBMIT_DIR"
echo " the name of the job is: $SLURM_JOB_NAME"
echo "Th job ID is $SLURM_JOB_ID"
echo "The job was run on these nodes: $SLURM_JOB_NODELIST"
echo "Number of nodes: $SLURM_JOB_NUM_NODES"
echo "We are using $SLURM_CPUS_ON_NODE cores"
echo "We are using $SLURM_CPUS_ON_NODE cores per node"
echo "Total of $SLURM_NTASKS cores"
module purge
module load GCCcore/13.3.0
./diann-linux --lib "" --threads 128 --verbose 2 --out "humanL10to30peptides.parquet" --qvalue 0.01 --matrices  --out-lib "humanL10to30peptideslib.parquet" --gen-spec-lib --predictor --fasta "/cluster/projects/nn9036k/FastaDB/UP000005640_9606_unique_gene.len10to30.hdrfix.fasta" --fasta-search --min-fr-mz 200 --max-fr-mz 1800 --met-excision --min-pep-len 10 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --cut Z* --missed-cleavages 0 --unimod4 --mass-acc 15.0 --mass-acc-ms1 15.0 --reanalyse --rt-profiling


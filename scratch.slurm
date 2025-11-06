#!/bin/sh
#SBATCH --account=nn9036k --job-name=ppm15DIAfX
##SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=20
#SBATCH --mem-per-cpu=8G
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
cd /cluster/projects/nn9036k/diann-2.3.0/
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
./diann-linux --f "251030_MAREN_DIALYSE_DIA_Slot1-37_1_11509.d" --lib "" --threads 80 --verbose 5 --out "report.ppm15.parquet" --qvalue 0.01 --matrices  --out-lib "replib.ppm15.parquet" --gen-spec-lib --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "UP000005640_9606_1protein1gene_additional.fasta" --fasta "UP000005640_9606_1protein1gene.fasta" --pre-search --pre-filter --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --min-fr-mz 200 --max-fr-mz 1800 --cut ** --missed-cleavages 100 --unimod4 --var-mods 5 --var-mod UniMod:35,15.994915,M --var-mod UniMod:7,0.984016,NQ --var-mod UniMod:1,42.010565,*n --var-mod UniMod:21,79.966331,STY --mass-acc 15 --mass-acc-ms1 15 --peptidoforms --reanalyse --rt-profiling
#cp -rf *.fasta /cluster/projects/nn9036k/FastaDB/.
#dos2unix slurmDIANN.sh scratch.slurm


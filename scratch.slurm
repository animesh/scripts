#!/bin/sh
#SBATCH --account=nn9036k --job-name=TestFile.dppm15bmaraport
#SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=16
#SBATCH --mem-per-cpu=16G
#SBATCH --time=24:00:00
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=TestFile.dppm15bmaraport.log
#wget "https://objects.githubusercontent.com/github-production-release-asset-2e65be/125283280/6d0978fc-15e7-41d3-9f1b-027a7b889780?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=releaseassetproduction%2F20250530%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250530T135309Z&X-Amz-Expires=300&X-Amz-Signature=195fa2d2efe5aca54ca53637ec411c012988efd2d0fa6b0b989acd8f2a81d802&X-Amz-SignedHeaders=host&response-content-disposition=attachment%3B%20filename%3DDIA-NN-2.2.0-Academia-Linux.zip&response-content-type=application%2Foctet-stream" -O diannv2p2.zip
#unzip diannv2p2.zip
#mv diann-2.2.0 /cluster/projects/nn9036k/.
#chmod 755 /cluster/projects/nn9036k/diann-2.2.0/diann-linux
#cp /cluster/projects/nn9036k/diann-2.1.0/*.fasta /cluster/projects/nn9036k/diann-2.2.0/.
#mkdir barbara
#rsync -Parv /nird/datapeak/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2026/260528_barbara/260528_Barbara_*.d barbara/.
#cp /nird/datapeak/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/FastaDB/humanMC2V3defaults.predicted.speclib barbara/.
#cp /nird/datapeak/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/FastaDB/UP000005640_9606_1protein1gene.fasta barbara/.
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
./diann-linux  --f TestFile.d  --lib sonaliMC2V3ppm15defaults.predicted.speclib --threads 64 --verbose 1 --out TestFile.dreport.ppm15bm.parquet --qvalue 0.01 --matrices  --out-lib TestFile.dreport-lib.ppm15bm.parquet --gen-spec-lib --reannotate --fasta sonali_combined.fasta --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --mass-acc 15.0 --mass-acc-ms1 15.0 --direct-quant --window 5  --peptidoforms --rt-profiling 
#dos2unix  scratch.slurm
#sbatch  scratch.slurm
#tail -f ppm15bmaraport.log

#!/bin/sh
#SBATCH --account=nn9036k --job-name=TestFile.d.WRITEFILE
##SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=10
#SBATCH --mem-per-cpu=8G
#SBATCH --time=24:00:00
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=TestFile.d.WRITEFILE.log
#wget "https://objects.githubusercontent.com/github-production-release-asset-2e65be/125283280/6d0978fc-15e7-41d3-9f1b-027a7b889780?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=releaseassetproduction%2F20250530%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250530T135309Z&X-Amz-Expires=300&X-Amz-Signature=195fa2d2efe5aca54ca53637ec411c012988efd2d0fa6b0b989acd8f2a81d802&X-Amz-SignedHeaders=host&response-content-disposition=attachment%3B%20filename%3DDIA-NN-2.2.0-Academia-Linux.zip&response-content-type=application%2Foctet-stream" -O diannv2p2.zip
#unzip diannv2p2.zip
#mv diann-2.2.0 /cluster/projects/nn9036k/.
#chmod 755 /cluster/projects/nn9036k/diann-2.2.0/diann-linux
#cp /cluster/projects/nn9036k/diann-2.1.0/*.fasta /cluster/projects/nn9036k/diann-2.2.0/.
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
#diann.exe --lib "" --threads 32 --verbose 1 --out "C:\Temp\report.parquet" --qvalue 0.01 --matrices  --out-lib "L:\promec\FastaDB\humanMC2V3defaults.parquet" --gen-spec-lib --predictor --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "L:\promec\FastaDB\UP000005640_9606_unique_gene.fasta" --fasta-search --min-fr-mz 200 --max-fr-mz 1800 --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --peptidoforms --reanalyse --rt-profiling 
#cp -rf /nird/projects/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/FastaDB/humanMC2V3defaults.predicted.speclib /cluster/projects/nn9036k/FastaDB/.
./diann-linux --f "TestFile.d" --lib "/cluster/projects/nn9036k/FastaDB/humanMC2V3defaults.predicted.speclib" --gen-spec-lib --threads 40 --verbose 1 --out "TestFile.d.WRITEFILE.report.parquet" --qvalue 0.01 --matrices  --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "UP000005640_9606_unique_gene.fasta" --fasta-search --min-fr-mz 200 --max-fr-mz 1800 --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --mass-acc 15.0 --mass-acc-ms1 15.0 --peptidoforms --rt-profiling  --use-quant --direct-quant  
#dos2unix slurmDIANN.sh scratch.slurm


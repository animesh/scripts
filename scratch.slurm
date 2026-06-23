#!/bin/sh
#SBATCH --account=nn9036k --job-name=TestFile.d.MC2V3
##SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=20
#SBATCH --mem-per-cpu=8G
#SBATCH --time=160:00:00
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=TestFile.d.MC2V3.log
cd /cluster/home/ash022/cluster/diann-2.5.1
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
module load GCCcore/14.3.0
module --ignore_cache load dotNET-Core/8.0.411
#wget https://github.com/vdemichev/DiaNN/releases/download/2.0/DIA-NN-2.5.1-Academia-Linux.zip
#unzip DIA-NN-2.5.1-Academia-Linux.zip
#chmod 755 diann-linux
#cp ../diann-2.5.0/camprotR_240512_cRAP_20190401_full_tags.fasta .
#grep "^>" /cluster/home/ash022/cluster/diann-2.3.0/UP000005640_9606_unique_gene.fasta | wc
#  20644  226158 2076619
./diann-linux --f TestFile.d  --threads 80 --verbose 1 --out TestFile.d.report.parquet --qvalue 0.01 --no-rt-window --out-lib TestFile.d.lib.parquet --gen-spec-lib --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta /cluster/home/ash022/cluster/diann-2.3.0/UP000005640_9606_unique_gene.fasta --pre-search --pre-filter --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --min-fr-mz 200 --max-fr-mz 1800 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --mass-acc 10 --mass-acc-ms1 4 --mass-acc-cal 13 --proteoforms --reanalyse --rt-profiling --direct-quant --global-norm --original-mods  --export-quant --dda

#dos2unix scratch.slurm 
#sbatch scratch.slurm 

#!/bin/sh
#SBATCH --account=nn9036k --job-name=TestFile.dC1MC2V3dNQdefaults
#SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=32
#SBATCH --mem-per-cpu=16G
#SBATCH --time=160:00:00
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=TestFile.dC1MC2V3dNQdefaults.log
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
#wget https://github.com/vdemichev/DiaNN/releases/download/2.0/DIA-NN-2.5.1-Academia-Linux.zip
#unzip DIA-NN-2.5.1-Academia-Linux.zip
#chmod 755 diann-linux
#cp ../diann-2.5.0/camprotR_240512_cRAP_20190401_full_tags.fasta .
#no wget https://rest.uniprot.org/uniprotkb/stream?download=true&format=fasta&includeIsoform=true&query=%28%28proteome%3AUP001652741%29%29
#cp 
FastaDB/sonali*fasta .
#wc sonali_combined.fasta 
#   7082969  13033644 450658590 sonali_combined.fasta
#./diann-linux --lib --threads 128 --verbose 1 --out --qvalue 0.01 --matrices --out-lib sonaliC1MC2defaults.parquet --gen-spec-lib --predictor --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta sonali_combined.fasta --fasta-search --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --min-fr-mz 200 --max-fr-mz 1800 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:7,0.984016,NQ --var-mod UniMod:1,42.010565,*n --rt-profiling --original-mods 
./diann-linux --f TestFile.d --lib sonaliC1MC2defaults.predicted.speclib --threads 128 --verbose 1 --out TestFile.d.report.sonaliC1MC2defaults.predicted.speclib.parquet --qvalue 0.01 --matrices --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta sonali_combined.fasta --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --min-fr-mz 200 --max-fr-mz 1800 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:7,0.984016,NQ --var-mod UniMod:1,42.010565,*n --mass-acc 15 --mass-acc-ms1 15 --reanalyse --rt-profiling --high-acc --original-mods
#dos2unix scratch.slurm 
#sbatch scratch.slurm 
#tail -f TestFile.dC1MC2V3dNQdefaults.log 
|
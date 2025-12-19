#!/bin/sh
#SBATCH --account=nn9036k --job-name=DIANN.WRITEFILE
##SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=20
#SBATCH --mem-per-cpu=8G
#SBATCH --time=48:00:00
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=TestFile.d.WRITEFILE.ppm15DIAmix.log
# wget "https://github.com/vdemichev/DiaNN/releases/download/2.0/DIA-NN-2.3.1-Academia-Linux.zip"
# sha256sum ./DIA-NN-2.3.1-Academia-Linux.zip 
#614dba4449e06358469fbe443826658749f610d6e015ed4c771ec645e8457eb4  ./DIA-NN-2.3.1-Academia-Linux.zip
# unzip ./DIA-NN-2.3.1-Academia-Linux.zip
cd /cluster/home/ash022/scripts/diann-2.3.1
#cp /cluster/projects/nn9036k/diann-2.3.0/camprotR_240512_cRAP_20190401_full_tags.fasta . 
#chmod 755 diann-linux 
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
./diann-linux --f TestFile.d --lib "" --threads 80 --verbose 5 --out "TestFile.d.WRITEFILE.parquet" --qvalue 0.01 --matrices  --out-lib "TestFile.d.WRITEFILE.lib.parquet" --gen-spec-lib --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "/cluster/home/ash022/scripts/maike/UP000000589_10090.fasta" --pre-search --pre-filter --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --min-fr-mz 200 --max-fr-mz 1800 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:7,0.984016,NQ --var-mod UniMod:1,42.010565,*n --mass-acc 15 --mass-acc-ms1 15 --individual-mass-acc --individual-windows --peptidoforms --rt-profiling  --reanalyse
#tail -f BMppm15DIAmix.log 
#dos2unix scratch.slurm  slurmDIANN.sh
#bash slurmDIANN.sh /cluster/home/ash022/scripts



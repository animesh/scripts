#!/bin/sh
#SBATCH --account=nn9036k --job-name=TestFile.dppm15DIAsteven
##SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=10
#SBATCH --mem-per-cpu=4G
#SBATCH --time=96:00:00
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=TestFile.dppm15DIAsteven.log
cd /cluster/home/ash022/cluster/diann-2.5.0
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
##diann.exe --lib  --threads 12 --verbose 3 --out  --qvalue 0.01 --matrices --out-lib L:\promec\TIMSTOF\LARS\2026\260408_Steven\libV2p5mc2v3dNQ.parquet --gen-spec-lib --predictor --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta L:\promec\TIMSTOF\LARS\2026\260408_Steven\uniprotkb_proteome_UP000006548_2026_04_13.fasta --fasta-search --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 2 --max-pr-charge 4 --min-fr-mz 200 --max-fr-mz 1800 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --rt-profiling --original-mods
./diann-linux --f TestFile.d --lib /cluster/home/ash022/scripts/steven2/libV2p5mc2v3dNQ.predicted.speclib --threads 40 --verbose 1 --out TestFile.d.report.parquet --qvalue 0.01 --matrices --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta /cluster/home/ash022/scripts/steven2/uniprotkb_proteome_UP000006548_2026_04_13.fasta --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 2 --max-pr-charge 4 --min-fr-mz 200 --max-fr-mz 1800 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --mass-acc 15 --mass-acc-ms1 15 --reanalyse --rt-profiling --original-mods
#dos2unix scratch.slurm
#tail -f BMppm15DIAmix.log 



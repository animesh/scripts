#!/bin/sh
#SBATCH --account=nn9036k --job-name=TestFile.d.MC2V3
##SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=20
#SBATCH --mem-per-cpu=8G
#SBATCH --time=160:00:00
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=TestFile.d.MC2V3.log
cd /cluster/projects/nn9036k/diann-2.6.0/ 
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
#wget https://github.com/vdemichev/DiaNN/releases/download/2.0/DIA-NN-2.6.0-Academia-Linux.zip
#wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000005640/UP000005640_9606.fasta.gz
#gunzip UP000005640_9606.fasta.gz
#mv UP000005640_9606.fasta promec/promec/FastaDB/UP000005640_9606_1protein1gene.fasta
#unzip DIA-NN-2.6.0-Academia-Linux.zip
#chmod 755 diann-linux
#cp ../diann-2.5.0/camprotR_240512_cRAP_20190401_full_tags.fasta .
#grep "^>" promec/promec/FastaDB/UP000005640_9606_1protein1gene.fasta | wc
#  20663  226312 2078446
#unzip DIA-NN-2.6.0-Academia-Linux.zip
#cp -rf diann-2.6.0 /cluster/projects/nn9036k/.
#cp -rf /cluster/projects/nn9036k/diann-2.3.0/*.fasta /cluster/projects/nn9036k/diann-2.6.0/
#rsync -Parv /nird/datapeak/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/FastaDB/humanMC2V3.2p6.predicted.speclib  /cluster/projects/nn9036k/diann-2.6.0/
#diann.exe --lib  --threads 24 --verbose 1 --out  --qvalue 0.01 --matrices --out-lib L:\promec\FastaDB\humanMC2V3.2p6.parquet --gen-spec-lib --predictor --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta L:\promec\FastaDB\UP000005640_9606_1protein1gene.fasta --fasta-search --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --min-fr-mz 200 --max-fr-mz 1800 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --rt-profiling --original-mods
#diann.exe --f Z:\Download\timsread\Fig2A-E_raw\250128_Hela_1ug_nDIA_3ms_R3.raw --f Z:\Download\timsread\Fig2A-E_raw\250128_Hela_1ug_nDIA_3ms_R2.raw --f Z:\Download\timsread\Fig2A-E_raw\250128_Hela_1ug_nDIA_3ms_R1.raw --f Z:\Download\timsread\Fig2A-E_raw\250128_Hela_1ng_nDIA_3ms_R3.raw --f Z:\Download\timsread\Fig2A-E_raw\250128_Hela_1ng_nDIA_3ms_R2.raw --f Z:\Download\timsread\Fig2A-E_raw\250128_Hela_1ng_nDIA_3ms_R1.raw --f Z:\Download\timsread\Fig2A-E_raw\250128_Hela_100ng_nDIA_3ms_R3.raw --f Z:\Download\timsread\Fig2A-E_raw\250128_Hela_100ng_nDIA_3ms_R2.raw --f Z:\Download\timsread\Fig2A-E_raw\250128_Hela_100ng_nDIA_3ms_R1.raw --lib L:\promec\FastaDB\humanMC2V3.2p6.predicted.speclib --threads 9 --verbose 1 --out F:\\nDDA\report.DIA9.2p6.parquet --qvalue 0.01 --matrices --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta L:\promec\FastaDB\UP000005640_9606_1protein1gene.fasta --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --min-fr-mz 200 --max-fr-mz 1800 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --window 10 --mass-acc 10 --mass-acc-ms1 10 --peptidoforms --reanalyse --rt-profiling --direct-quant --original-mods --export-quant
./diann-linux --f  --threads 80 --verbose 1 --out TestFile.d.dia.report.parquet --qvalue 0.01 --no-rt-window --out-lib TestFile.dia.lib.parquet 
 --lib /cluster/projects/nn9036k/diann-2.6.0/humanMC2V3.2p6.predicted.speclib --threads 80 --verbose 1 --out TestFile.d.report.DIA.2p6.parquet --qvalue 0.01 --matrices --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta /cluster/projects/nn9036k/diann-2.6.0/UP000005640_9606_1protein1gene.fasta --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --min-fr-mz 200 --max-fr-mz 1800 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --window 10 --mass-acc 10 --mass-acc-ms1 10 --peptidoforms --reanalyse --rt-profiling --direct-quant --original-mods --export-quant --dda
#diann.exe --f Z:\Download\timsread\Fig2A-E_raw\250128_Hela_100ng_DDA_3ms_R1.raw --f Z:\Download\timsread\Fig2A-E_raw\250128_Hela_100ng_DDA_3ms_R2.raw --f Z:\Download\timsread\Fig2A-E_raw\250128_Hela_100ng_DDA_3ms_R3.raw --f Z:\Download\timsread\Fig2A-E_raw\250128_Hela_1ng_DDA_3ms_R1.raw --f Z:\Download\timsread\Fig2A-E_raw\250128_Hela_1ng_DDA_3ms_R2.raw --f Z:\Download\timsread\Fig2A-E_raw\250128_Hela_1ng_DDA_3ms_R3.raw --f Z:\Download\timsread\Fig2A-E_raw\250128_Hela_1ug_DDA_3ms_R2.raw --f Z:\Download\timsread\Fig2A-E_raw\250128_Hela_1ug_DDA_3ms_R3.raw --f Z:\Download\timsread\Fig2A-E_raw\250128_Hela_1ug_DDA_3ms_R1.raw --lib L:\promec\FastaDB\humanMC2V3.2p6.predicted.speclib --threads 9 --verbose 1 --out F:\\nDDA\report.DDA9.2p6.parquet --qvalue 0.01 --matrices --out-lib F:\\nDDA\report.DDA9.2p6-lib.parquet --gen-spec-lib --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta L:\promec\FastaDB\UP000005640_9606_1protein1gene.fasta --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --min-fr-mz 200 --max-fr-mz 1800 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --window 10 --mass-acc 10 --mass-acc-ms1 10 --peptidoforms --reanalyse --rt-profiling --direct-quant --original-mods --export-quant --dda
#dos2unix scratch.slurm 
#sbatch scratch.slurm 

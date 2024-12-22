#!/bin/sh
#SBATCH --account=nn9036k --job-name=salhumDIANN
#SBATCH --time=24:00:00
##SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=20
#SBATCH --mem-per-cpu=4G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=salhumDIANNLOGlin

#wget https://github.com/vdemichev/DiaNN/releases/download/1.9.2/diann-1.9.2.Linux.zip
#unzip diann-1.9.2.Linux.zip
#chmod +x diann-linux

cd /cluster/projects/nn9036k/diann-1.9.2
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
#windows
#diann.exe --lib "" --threads 32 --verbose 1 --out "C:\/Temp/report.tsv" --qvalue 0.01 --matrices  --out-lib "F:\promec\FastaDB\UP000005640_9606_unique_gene_C24_MC1_P735_MZ1001700_Mod3.parquet" --gen-spec-lib --predictor --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "F:\promec\FastaDB\UP000005640_9606_unique_gene.fasta" --fasta-search --min-fr-mz 100 --max-fr-mz 1700 --met-excision --min-pep-len 7 --max-pep-len 35 --min-pr-mz 100 --max-pr-mz 1700 --min-pr-charge 2 --max-pr-charge 4 --cut K*,R* --missed-cleavages 1 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --individual-mass-acc --individual-windows --peptidoforms --relaxed-prot-inf --rt-profiling
#wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000005640/UP000005640_9606.fasta.gz
#gunzip UP000005640_9606.fasta.gz
#mv UP000005640_9606.fasta UP000005640_9606_unique_gene.fasta
#wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000087266/UP000087266_8030.fasta.gz
#gunzip UP000087266_8030.fasta.gz
#mv UP000087266_8030.fasta UP000087266_8030_unique_gene.fasta
#cat UP000005640_9606_unique_gene.fasta UP000087266_8030_unique_gene.fasta > /cluster/projects/nn9036k/FastaDB/UP000005640_9606_UP000087266_8030_unique_gene.fasta
#grep "^>" /cluster/projects/nn9036k/FastaDB/UP000005640_9606_UP000087266_8030_unique_gene.fasta | wc #  68960  763398 7700217
./diann-linux --threads 20 --verbose 1 --out "/cluster/projects/nn9036k/FastaDB/UP000005640_9606_UP000087266_8030_unique_gene_MC0_L35_C57_vMod0.report.tsv" --gen-spec-lib --predictor --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --fasta "/cluster/projects/nn9036k/FastaDB/UP000005640_9606_UP000087266_8030_unique_gene.fasta" --fasta-search  --unimod4 --max-pep-len 35 --missed-cleavages 0
#[0:33] 4270041 precursors generated
#[0:32] Library contains 68890 proteins, and 66271 genes
./diann-linux  --f "/cluster/projects/nn9036k/scripts/dia/241217_20ngHelaQC_DIAc_Slot1-28_1_9292.d" --f "/cluster/projects/nn9036k/scripts/dia/241217_20ngHelaQC_DIAb_Slot1-28_1_9290.d" --f "/cluster/projects/nn9036k/scripts/dia/241217_20ngHelaQC_DIAa_Slot1-28_1_9288.d" --f "/cluster/projects/nn9036k/scripts/dia/241217_2ngHelaQC_DIAc_Slot1-29_1_9298.d" --f "/cluster/projects/nn9036k/scripts/dia/241217_2ngHelaQC_DIAb_Slot1-29_1_9296.d" --f "/cluster/projects/nn9036k/scripts/dia/241217_2ngHelaQC_DIAa_Slot1-29_1_9294.d" --f "/cluster/projects/nn9036k/scripts/dia/241217_200ngHelaQC_DIA_Slot1-54_1_9286.d" --lib "/cluster/projects/nn9036k/FastaDB/UP000005640_9606_UP000087266_8030_unique_gene_MC0_L35_C57_vMod0.report-lib.predicted.speclib" --threads 20 --verbose 1 --out "/cluster/projects/nn9036k/scripts/dia/DIANN1p9p2\Salmon\reportMC0VM0.tsv" --qvalue 0.01 --matrices  --min-corr 2.0 --corr-diff 1.0 --time-corr-only --unimod4 --direct-quant --no-norm --no-maxlfq --mass-acc 20.0 --mass-acc-ms1 20  --export-quant --no-fr-selection --cont-quant-exclude cRAP- --fasta "/cluster/projects/nn9036k/FastaDB/UP000005640_9606_UP000087266_8030_unique_gene.fasta"
#[0:16] Library annotated with sequence database(s): camprotR_240512_cRAP_20190401_full_tags.fasta; /cluster/projects/nn9036k/FastaDB/UP000005640_9606_UP000087266_8030_unique_gene.fasta
#[0:19] Spectral library loaded: 68890 protein isoforms, 127462 protein groups and 4270041 precursors in 1360416 elution groups.
#[0:21] Library contains 68890 proteins, and 66271 genes
#5:40] RT window set to 3.09066
#[5:40] Ion mobility window set to 0.0337944
#[5:40] Peak width: 4.232
#[5:40] Scan window radius set to 9
#[5:40] Recommended MS1 mass accuracy setting: 13.3985 ppm
#[8:34] Training neural networks on 105888 PSMs
#[8:40] Number of IDs at 0.01 FDR: 44295
#[8:41] Calculating protein q-values
#[8:42] Number of genes identified at 1% FDR: 5457 (precursor-level), 4906 (protein-level) (inference performed using proteotypic peptides only)


#!/bin/sh
#SBATCH --account=nn9036k --job-name=alessandroDIANN
#SBATCH --time=160:00:00
##SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=20
#SBATCH --mem-per-cpu=8G
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=logDIANNalessandro.out

#rm -rf diann-2.0/
#wget "https://objects.githubusercontent.com/github-production-release-asset-2e65be/125283280/9008896b-6283-4cc9-9b3b-5ab02c2aee9f?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=releaseassetproduction%2F20250320%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20250320T121704Z&X-Amz-Expires=300&X-Amz-Signature=7692685c9088483c025b3a85d0276c15e1b912d0aea77fb85bc58b8526c8ed20&X-Amz-SignedHeaders=host&response-content-disposition=attachment%3B%20filename%3DDIA-NN-2.0-Academia-Linux.zip&response-content-type=application%2Foctet-stream" -O diann.acad.linux.zip
#unzip diann.acad.linux.zip
cd /cluster/projects/nn9036k/diann-2.0
#cp /cluster/projects/nn9036k/diann-1.9.2/camprotR_240512_cRAP_20190401_full_tags.fasta .
#chmod +x diann-linux

export PATH=$PATH:$PWD
export NCPU=20
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

#wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000005640/UP000005640_9606.fasta.gz
#gunzip UP000005640_9606.fasta.gz
#mv UP000005640_9606.fasta /cluster/projects/nn9036k/FastaDB/UP000005640_9606_unique_gene.fasta
#cp -rf /nird/datapeak/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2025/250319_Alessandro/250319_Alessan*_DIA*.d .
#mkdir /nird/datapeak/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2025/250319_Alessandro/DIANNv2lin
./diann-linux --lib "" --threads $NCPU --verbose 1 --out "/cluster/projects/nn9036k/FastaDB/UP000005640_9606_unique_gene_C24_MC1_P735_MZ1001700_Mod3.parquet" --qvalue 0.01 --matrices  --out-lib "/cluster/projects/nn9036k/FastaDB/UP000005640_9606_unique_gene_C24_MC1_P735_MZ1001700_Mod3.predicted.speclib" --gen-spec-lib --predictor --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "/cluster/projects/nn9036k/FastaDB/UP000005640_9606_unique_gene.fasta" --fasta-search --min-fr-mz 100 --max-fr-mz 1700 --met-excision --min-pep-len 7 --max-pep-len 35 --min-pr-mz 100 --max-pr-mz 1700 --min-pr-charge 2 --max-pr-charge 4 --cut K*,R* --missed-cleavages 1 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --mass-acc 20.0 --mass-acc-ms1 20 --individual-mass-acc --individual-windows --peptidoforms --reanalyse --rt-profiling
./diann-linux --f "/cluster/projects/nn9036k/diann-2.0/250319_Alessandro_Cancer_DIA_Slot1-38_1_9860.d" --f "250319_Alessandro_Normal_DIA_Slot1-37_1_9858.d" --lib "/cluster/projects/nn9036k/FastaDB/UP000005640_9606_unique_gene_C24_MC1_P735_MZ1001700_Mod3.predicted.predicted.speclib" --threads $NCPU --verbose 1 --out "report.$NCPU.parquet" --qvalue 0.01 --matrices  --out-lib "report.$NCPU.parquetreport-lib.parquet" --gen-spec-lib --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "/cluster/projects/nn9036k/FastaDB/UP000005640_9606_unique_gene.fasta" --met-excision --min-pep-len 7 --max-pep-len 35 --min-pr-mz 100 --max-pr-mz 1700 --min-pr-charge 2 --max-pr-charge 4 --cut K*,R* --missed-cleavages 1 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:1,42.010565,*n --mass-acc 20.0 --mass-acc-ms1 20 --individual-mass-acc --individual-windows --peptidoforms --reanalyse --rt-profiling

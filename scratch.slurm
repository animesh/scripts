#!/bin/bash

DIANN_DIR=${1:-"/cluster/projects/nn9036k/diann-2.7.0"}
CLEAN_DIR="${DIANN_DIR%/}"
CLEAN_DIR="${CLEAN_DIR// /}"
DIANN_DIR_NAME="${CLEAN_DIR##*/}"
FASTA_FILE=${2:-"UP000005640_9606.fasta"}
RAW_DIR=${3:-"/cluster/projects/nn9036k/scrbkup/paola"}
TARGET_RAW="TestFile.d"

RAW_BASENAME=$(basename "$TARGET_RAW" .d)
FASTA_BASENAME=$(basename "$FASTA_FILE" .fasta)
DIANN_RESULTS_DIR="$RAW_DIR/$RAW_BASENAME.$DIANN_DIR_NAME.$FASTA_BASENAME.${SLURM_JOB_ID}.results"
mkdir -p "$DIANN_RESULTS_DIR"
FASTA_LIBNAME="humMC1V2dNQpr1to1700.predicted.speclib"
PARQUET_FILE="${FASTA_BASENAME}.parquet"
OUTPUT_REPORT="${FASTA_BASENAME}.tsv"

cd "$DIANN_DIR"
export PATH=$PATH:$PWD

module purge
module load GCCcore/15.2.0
#module --ignore_cache load dotNET-Core/8.0.411

#wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000005640/UP000005640_9606.fasta.gz
#gunzip UP000005640_9606.fasta.gz 

cp -u "$FASTA_FILE" "$DIANN_DIR/"
cp -u "/cluster/projects/nn9036k/diann-2.2.0/camprotR_240512_cRAP_20190401_full_tags.fasta" "$DIANN_DIR/"

#./diann-linux --lib  --threads 20 --verbose 1 --out  --qvalue 0.05 --matrices --out-lib humMC1V2dNQpr1to1700.parquet --gen-spec-lib --predictor --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta UP000005640_9606.fasta --fasta-search --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 100 --max-pr-mz 1700 --min-pr-charge 1 --max-pr-charge 4 --min-fr-mz 400 --max-fr-mz 1000 --cut K*,R* --missed-cleavages 1 --unimod4 --var-mods 2 --var-mod UniMod:35,15.994915,M --var-mod UniMod:7,0.984016,NQ --var-mod UniMod:1,42.010565,*n --rt-profiling --high-acc --original-mods

./diann-linux \
  --f "$TARGET_RAW" \
  --lib "$FASTA_LIBNAME" \
  --threads 80 \
  --verbose 1 \
  --out "$DIANN_RESULTS_DIR/report.parquet" \
  --qvalue 0.05 \
  --matrices \
  --reannotate \
  --fasta camprotR_240512_cRAP_20190401_full_tags.fasta \
  --cont-quant-exclude cRAP- \
  --fasta "$(basename "$FASTA_FILE")" \
  --met-excision \
  --min-pep-len 7 --max-pep-len 30 \
  --min-pr-mz 100 --max-pr-mz 1700 \
  --min-pr-charge 1 --max-pr-charge 4 \
  --min-fr-mz 400 --max-fr-mz 1000 \
  --cut K*,R* \
  --missed-cleavages 1 \
  --unimod4 \
  --var-mods 2 \
  --var-mod UniMod:35,15.994915,M \
  --var-mod UniMod:7,0.984016,NQ \
  --var-mod UniMod:1,42.010565,*n \
  --window 30 \
  --mass-acc 30 \
  --mass-acc-ms1 30 \
  --peptidoforms \
  --reanalyse \
  --rt-profiling \
  --original-mods
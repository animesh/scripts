#!/bin/bash
#SBATCH --account=nn9036k 
#SBATCH --job-name=diann_job
##SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=20
#SBATCH --mem-per-cpu=8G
#SBATCH --time=24:00:00
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=WRITEFILE_%j.log

DIANN_DIR=${1:-"/cluster/projects/nn9036k/diann-2.7.0"}
CLEAN_DIR="${DIANN_DIR%/}"
CLEAN_DIR="${CLEAN_DIR// /}"
DIANN_DIR_NAME="${CLEAN_DIR##*/}"
FASTA_FILE=${2:-"UP000000589_10090.fasta"}
RAW_DIR=${3:-"/cluster/projects/nn9036k/scrbkup/maike23"}
TARGET_RAW="TestFile.d"

RAW_BASENAME=$(basename "$TARGET_RAW" .d)
FASTA_BASENAME=$(basename "$FASTA_FILE" .fasta)
DIANN_RESULTS_DIR="$RAW_DIR/$RAW_BASENAME.$DIANN_DIR_NAME.$FASTA_BASENAME.${SLURM_JOB_ID}.results"
mkdir -p "$DIANN_RESULTS_DIR"
FASTA_LIBNAME="${FASTA_BASENAME}.predicted.speclib"
PARQUET_FILE="${FASTA_BASENAME}.parquet"
OUTPUT_REPORT="${FASTA_BASENAME}.tsv"

cd "$DIANN_DIR"
export PATH=$PATH:$PWD

module purge
module load GCCcore/14.3.0
module --ignore_cache load dotNET-Core/8.0.411

cp -u "$FASTA_FILE" "$DIANN_DIR/"
cp -u "/cluster/projects/nn9036k/diann-2.2.0/camprotR_240512_cRAP_20190401_full_tags.fasta" "$DIANN_DIR/"

./diann-linux \
  --f "$TARGET_RAW" \
  --lib "$FASTA_LIBNAME" \
  --threads ${SLURM_CPUS_PER_TASK:-20} \
  --verbose 1 \
  --out "$DIANN_RESULTS_DIR/report.parquet" \
  --qvalue 0.01 \
  --matrices \
  --reannotate \
  --fasta camprotR_240512_cRAP_20190401_full_tags.fasta \
  --cont-quant-exclude cRAP- \
  --fasta "$(basename "$FASTA_FILE")" \
  --met-excision \
  --min-pep-len 7 --max-pep-len 30 \
  --min-pr-mz 300 --max-pr-mz 1800 \
  --min-pr-charge 1 --max-pr-charge 4 \
  --min-fr-mz 200 --max-fr-mz 1800 \
  --cut K*,R* \
  --missed-cleavages 2 \
  --unimod4 \
  --var-mods 3 \
  --var-mod UniMod:35,15.994915,M \
  --var-mod UniMod:7,0.984016,NQ \
  --var-mod UniMod:1,42.010565,*n \
  --window 27 \
  --mass-acc 20 \
  --mass-acc-ms1 20 \
  --peptidoforms \
  --reanalyse \
  --rt-profiling \
  --original-mods
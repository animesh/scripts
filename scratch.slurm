#!/bin/bash
#SBATCH --account=nn9036k 
#SBATCH --job-name=diann_job
#SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=32
#SBATCH --mem-per-cpu=8G
#SBATCH --time=48:00:00
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=diann_%j.log

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
cp "$FASTA_FILE" "$DIANN_DIR/"
cp "/cluster/projects/nn9036k/diann-2.2.0/camprotR_240512_cRAP_20190401_full_tags.fasta" "$DIANN_DIR/"
# Generate library from FASTA
#./diann-linux --lib  --threads 20 --verbose 1 --out  --qvalue 0.05 --matrices --out-lib humMC1V2dNQpr1to1700.parquet --gen-spec-lib --predictor --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta UP000005640_9606.fasta --fasta-search --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 100 --max-pr-mz 1700 --min-pr-charge 1 --max-pr-charge 4 --min-fr-mz 400 --max-fr-mz 1000 --cut K*,R* --missed-cleavages 1 --unimod4 --var-mods 2 --var-mod UniMod:35,15.994915,M --var-mod UniMod:7,0.984016,NQ --var-mod UniMod:1,42.010565,*n --rt-profiling --high-acc --original-mods


# Build the dynamic list of --f arguments for all *.d files in RAW_DIR
RAW_ARGS=""
for d in "${RAW_DIR}"/*.d; do
  [ -d "$d" ] && RAW_ARGS="$RAW_ARGS --f $d"
done

# Process raw data files against the generated library
./diann-linux $RAW_ARGS --lib "$FASTA_LIBNAME" --threads 80 --verbose 1 --out "$DIANN_RESULTS_DIR/report.parquet" --qvalue 0.05 --matrices --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "$(basename "$FASTA_FILE")" --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 100 --max-pr-mz 1700 --min-pr-charge 1 --max-pr-charge 4 --min-fr-mz 400 --max-fr-mz 1000 --cut K*,R* --missed-cleavages 1 --unimod4 --var-mods 2 --var-mod UniMod:35,15.994915,M --var-mod UniMod:7,0.984016,NQ --var-mod UniMod:1,42.010565,*n --window 20 --mass-acc 20 --mass-acc-ms1 20 --peptidoforms --reanalyse --rt-profiling --original-mods --use-quant

#wget "https://github.com/vdemichev/DiaNN/releases/download/2.0/DIA-NN-2.7.0-Academia-Linux.zip"
#unzip DIA-NN-2.7.0-Academia-Linux.zip
#mv diann-2.7.0 /cluster/projects/nn9036k/. 
#chmod 755 /cluster/projects/nn9036k/diann-2.7.0/diann-linux 
#wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000000589/UP000000589_10090.fasta.gz
#gunzip UP000000589_10090.fasta.gz
#mkdir maike23
#rsync -Parv /nird/datapeak/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2026/260925_Maike/260928_Maike_*.d maike23/
#sbatch scratch.slurm /cluster/projects/nn9036k/diann-2.7.0 UP000000589_10090.fasta /cluster/projects/nn9036k/scrbkup/maike23/

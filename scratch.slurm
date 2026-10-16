#!/bin/bash
#SBATCH --account=nn9036k 
#SBATCH --job-name=diann_job
#SBATCH --partition=bigmem
#SBATCH --ntasks=1 --cpus-per-task=32
#SBATCH --mem-per-cpu=8G
#SBATCH --time=192:00:00
#SBATCH --mail-user=animesh.sharma@ntnu.no
#SBATCH --mail-type=ALL
#SBATCH --output=diann_%j.log

DIANN_DIR=${1:-"/cluster/projects/nn9036k/diann-2.7.0"}
CLEAN_DIR="${DIANN_DIR%/}"
CLEAN_DIR="${CLEAN_DIR// /}"
DIANN_DIR_NAME="${CLEAN_DIR##*/}"
FASTA_FILE=${2:-"UP000000589_10090.fasta"}
RAW_DIR=${3:-"/cluster/projects/nn9036k/scrbkup/maike23"}
FASTA_BASENAME=$(basename "$FASTA_FILE" .fasta)
DIANN_RESULTS_DIR="$RAW_DIR/$DIANN_DIR_NAME.$FASTA_BASENAME.${SLURM_JOB_ID}.results"
mkdir -p "$DIANN_RESULTS_DIR"
FASTA_LIBNAME="${FASTA_BASENAME}.predicted.speclib"
PARQUET_FILE="${FASTA_BASENAME}.parquet"
OUTPUT_REPORT="${FASTA_BASENAME}.tsv"

cd "$DIANN_DIR"
export PATH=$PATH:$PWD

module purge
module load GCCcore/14.3.0
module --ignore_cache load dotNET-Core/8.0.411

cp "$FASTA_FILE" "$DIANN_DIR/"
cp "/cluster/projects/nn9036k/diann-2.2.0/camprotR_240512_cRAP_20190401_full_tags.fasta" "$DIANN_DIR/"

# Generate library from FASTA
#./diann-linux --threads 80 --verbose 1 --out "$OUTPUT_REPORT" --qvalue 0.01 --matrices --out-lib "$PARQUET_FILE" --gen-spec-lib --predictor --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "$(basename "$FASTA_FILE")" --fasta-search --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --min-fr-mz 200 --max-fr-mz 1800 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:7,0.984016,NQ --var-mod UniMod:1,42.010565,*n --rt-profiling --original-mods

# Build the dynamic list of --f arguments for all *.d files in RAW_DIR
RAW_ARGS=""
for d in "${RAW_DIR}"/*.d; do
  [ -d "$d" ] && RAW_ARGS="$RAW_ARGS --f $d"
done

# Process raw data files against the generated library
./diann-linux $RAW_ARGS --lib "$FASTA_LIBNAME" --threads 80 --verbose 1 --out "$DIANN_RESULTS_DIR/report.parquet" --qvalue 0.01 --matrices --reannotate --fasta camprotR_240512_cRAP_20190401_full_tags.fasta --cont-quant-exclude cRAP- --fasta "$(basename "$FASTA_FILE")" --met-excision --min-pep-len 7 --max-pep-len 30 --min-pr-mz 300 --max-pr-mz 1800 --min-pr-charge 1 --max-pr-charge 4 --min-fr-mz 200 --max-fr-mz 1800 --cut K*,R* --missed-cleavages 2 --unimod4 --var-mods 3 --var-mod UniMod:35,15.994915,M --var-mod UniMod:7,0.984016,NQ --var-mod UniMod:1,42.010565,*n --window 27 --mass-acc 20 --mass-acc-ms1 20 --peptidoforms --reanalyse --rt-profiling --original-mods --use-quant

#wget "https://github.com/vdemichev/DiaNN/releases/download/2.0/DIA-NN-2.7.0-Academia-Linux.zip"
#unzip DIA-NN-2.7.0-Academia-Linux.zip
#mv diann-2.7.0 /cluster/projects/nn9036k/. 
#chmod 755 /cluster/projects/nn9036k/diann-2.7.0/diann-linux 
#wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000000589/UP000000589_10090.fasta.gz
#gunzip UP000000589_10090.fasta.gz
#mkdir maike23
#rsync -Parv /nird/datapeak/NS9036K/NORSTORE_OSL_DISK/NS9036K/promec/promec/TIMSTOF/LARS/2026/260925_Maike/260928_Maike_*.d maike23/
#sbatch scratch.slurm /cluster/projects/nn9036k/diann-2.7.0 UP000000589_10090.fasta /cluster/projects/nn9036k/scrbkup/maike23/
